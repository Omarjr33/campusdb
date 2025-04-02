-- 1. Obtener los campers con la nota más alta en cada módulo
WITH RankedCampersByModule AS (
    SELECT 
        m.id_modulo,
        m.nombre AS modulo,
        c.id_camper,
        CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
        em.nota_final,
        RANK() OVER (PARTITION BY m.id_modulo ORDER BY em.nota_final DESC) AS ranking
    FROM 
        evaluacion_modulo em
    JOIN camper c ON em.id_camper = c.id_camper
    JOIN modulo m ON em.id_modulo = m.id_modulo
)
SELECT 
    modulo,
    nombre_camper,
    nota_final
FROM 
    RankedCampersByModule
WHERE 
    ranking = 1;

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    ROUND(AVG(em.nota_final), 2) AS promedio_ruta,
    (SELECT ROUND(AVG(nota_final), 2) FROM evaluacion_modulo) AS promedio_global,
    ROUND(AVG(em.nota_final) - (SELECT AVG(nota_final) FROM evaluacion_modulo), 2) AS diferencia_con_promedio
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    promedio_ruta DESC;

-- 3. Listar las áreas con más del 80% de ocupación
SELECT 
    a.nombre AS area,
    s.nombre AS sede,
    a.capacidad_max,
    COUNT(c.id_camper) AS campers_asignados,
    ROUND((COUNT(c.id_camper) / a.capacidad_max) * 100, 2) AS porcentaje_ocupacion
FROM 
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
JOIN grupo g ON a.id_area = g.id_area
JOIN camper c ON g.id_grupo = c.id_grupo
WHERE 
    c.id_estado = 4  -- Estado 'Cursando'
GROUP BY 
    a.id_area, a.nombre, s.nombre, a.capacidad_max
HAVING 
    (COUNT(c.id_camper) / a.capacidad_max) * 100 > 80
ORDER BY 
    porcentaje_ocupacion DESC;

-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas,
    ROUND((SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS tasa_aprobacion
FROM 
    trainer t
JOIN trainer_modulo tm ON t.id_trainer = tm.id_trainer
JOIN evaluacion_modulo em ON tm.id_modulo = em.id_modulo AND tm.id_grupo = em.id_grupo
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
HAVING 
    AVG(em.nota_final) < 70
    AND COUNT(DISTINCT em.id_evaluacion) >= 5  -- Al menos 5 evaluaciones para ser significativo
ORDER BY 
    promedio_notas;

-- 5. Consultar los campers cuyo promedio está por debajo del promedio general
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    g.nombre AS grupo,
    r.nombre AS ruta,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_camper,
    (SELECT ROUND(AVG(nota_final), 2) FROM evaluacion_modulo) AS promedio_global,
    ROUND(AVG(em.nota_final) - (SELECT AVG(nota_final) FROM evaluacion_modulo), 2) AS diferencia_con_promedio
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
GROUP BY 
    c.id_camper, c.nombres, c.apellidos, g.nombre, r.nombre
HAVING 
    AVG(em.nota_final) < (SELECT AVG(nota_final) FROM evaluacion_modulo)
ORDER BY 
    promedio_camper;

-- 6. Obtener los módulos con la menor tasa de aprobación
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) AS aprobados,
    SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) AS reprobados,
    ROUND((SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS tasa_aprobacion
FROM 
    modulo m
JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
HAVING 
    COUNT(em.id_evaluacion) >= 5  -- Al menos 5 evaluaciones para ser significativo
ORDER BY 
    tasa_aprobacion
LIMIT 5;

-- 7. Listar los campers que han aprobado todos los módulos de su ruta
SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    g.nombre AS grupo,
    r.nombre AS ruta,
    COUNT(DISTINCT em.id_modulo) AS modulos_evaluados,
    SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) AS modulos_reprobados
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
GROUP BY 
    c.id_camper, c.nombres, c.apellidos, g.nombre, r.nombre
HAVING 
    modulos_reprobados = 0
    AND modulos_evaluados = (
        SELECT COUNT(DISTINCT rm.id_modulo)
        FROM ruta_modulo rm
        WHERE rm.id_ruta = g.id_ruta
    )
ORDER BY 
    r.nombre, c.apellidos;

-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(DISTINCT CASE 
        WHEN em.estado = 'Reprobado' 
        THEN c.id_camper 
    END) AS campers_bajo_rendimiento,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
GROUP BY 
    r.id_ruta, r.nombre
HAVING 
    COUNT(DISTINCT CASE 
        WHEN em.estado = 'Reprobado' 
        THEN c.id_camper 
    END) > 10
ORDER BY 
    campers_bajo_rendimiento DESC;

-- 9. Calcular el promedio de rendimiento por SGDB principal
SELECT 
    bd.nombre AS sgbd_principal,
    COUNT(DISTINCT r.id_ruta) AS total_rutas,
    GROUP_CONCAT(DISTINCT r.nombre SEPARATOR ', ') AS rutas,
    COUNT(DISTINCT em.id_camper) AS total_campers_evaluados,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas,
    ROUND((SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS tasa_aprobacion
FROM 
    base_datos bd
JOIN ruta r ON bd.id_ruta = r.id_ruta
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
WHERE 
    bd.tipo = 'Principal'
GROUP BY 
    bd.nombre
ORDER BY 
    promedio_notas DESC;

-- 10. Listar los módulos con al menos un 30% de campers reprobados
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) AS reprobados,
    ROUND((SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS porcentaje_reprobacion
FROM 
    modulo m
JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
HAVING 
    (SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100 >= 30
    AND COUNT(em.id_evaluacion) >= 5  -- Al menos 5 evaluaciones para ser significativo
ORDER BY 
    porcentaje_reprobacion DESC;

-- 11. Mostrar el módulo más cursado por campers con riesgo alto
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(DISTINCT em.id_camper) AS total_campers,
    COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Alto' THEN c.id_camper END) AS campers_alto_riesgo,
    ROUND((COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Alto' THEN c.id_camper END) / COUNT(DISTINCT em.id_camper)) * 100, 2) AS porcentaje_alto_riesgo
FROM 
    modulo m
JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
JOIN camper c ON em.id_camper = c.id_camper
JOIN estado_camper ec ON c.id_estado = ec.id_estado
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
HAVING 
    COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Alto' THEN c.id_camper END) > 0
ORDER BY 
    campers_alto_riesgo DESC, porcentaje_alto_riesgo DESC
LIMIT 1;

-- 12. Consultar los trainers con más de 3 rutas asignadas
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT g.id_ruta) AS total_rutas,
    GROUP_CONCAT(DISTINCT r.nombre SEPARATOR ', ') AS rutas_asignadas
FROM 
    trainer t
JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
JOIN grupo g ON tg.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
HAVING 
    COUNT(DISTINCT g.id_ruta) > 3
ORDER BY 
    total_rutas DESC;

-- 13. Listar los horarios más ocupados por áreas
SELECT 
    h.jornada,
    CONCAT(h.hora_inicio, ' - ', h.hora_fin) AS horario,
    COUNT(DISTINCT a.id_area) AS total_areas,
    SUM(
        (SELECT COUNT(c2.id_camper)
         FROM camper c2
         JOIN grupo g2 ON c2.id_grupo = g2.id_grupo
         WHERE g2.id_area = a.id_area AND c2.id_estado = 4)
    ) AS total_campers,
    GROUP_CONCAT(DISTINCT CONCAT(a.nombre, ' (', s.nombre, ')') SEPARATOR ', ') AS areas_sedes
FROM 
    horario h
JOIN area_entrenamiento a ON h.id_horario = a.id_horario
JOIN sede s ON a.id_sede = s.id_sede
GROUP BY 
    h.id_horario, h.jornada, h.hora_inicio, h.hora_fin
ORDER BY 
    total_areas DESC, total_campers DESC;

-- 14. Consultar las rutas con el mayor número de módulos
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT rm.id_modulo) AS total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre SEPARATOR ', ') AS modulos
FROM 
    ruta r
JOIN ruta_modulo rm ON r.id_ruta = rm.id_ruta
JOIN modulo m ON rm.id_modulo = m.id_modulo
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    total_modulos DESC
LIMIT 5;

-- 15. Obtener los campers que han cambiado de estado más de una vez
-- Nota: Esta consulta es simulada ya que no tenemos una tabla de historial de estados
SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    ec.nombre_estado AS estado_actual,
    ec.nivel_riesgo,
    DATEDIFF(CURRENT_DATE, c.fecha_registro) AS dias_desde_registro,
    FLOOR(RAND() * 5) + 1 AS cambios_de_estado_simulados -- Simulación
FROM 
    camper c
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    FLOOR(RAND() * 5) + 1 > 1 -- Simulación de campers con más de un cambio
ORDER BY 
    cambios_de_estado_simulados DESC
LIMIT 10;

-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    m.nombre AS modulo,
    MAX(CASE WHEN ce.nombre = 'Evaluación Teórica' THEN de.nota ELSE NULL END) AS nota_teorica,
    MAX(CASE WHEN ce.nombre = 'Evaluación Práctica' THEN de.nota ELSE NULL END) AS nota_practica,
    MAX(CASE WHEN ce.nombre = 'Quizzes y Participación' THEN de.nota ELSE NULL END) AS nota_quizzes,
    em.nota_final
FROM 
    evaluacion_modulo em
JOIN camper c ON em.id_camper = c.id_camper
JOIN modulo m ON em.id_modulo = m.id_modulo
JOIN detalle_evaluacion de ON em.id_evaluacion = de.id_evaluacion
JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
GROUP BY 
    em.id_evaluacion, c.id_camper, m.id_modulo
HAVING 
    nota_teorica > nota_practica
ORDER BY 
    (nota_teorica - nota_practica) DESC;

-- 17. Listar los módulos donde la media de quizzes supera el 9 (90 en escala de 100)
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(DISTINCT em.id_camper) AS total_campers,
    ROUND(AVG(
        (SELECT de.nota
         FROM detalle_evaluacion de
         JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
         WHERE de.id_evaluacion = em.id_evaluacion AND ce.nombre = 'Quizzes y Participación')
    ), 2) AS promedio_quizzes
FROM 
    modulo m
JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
WHERE 
    EXISTS (
        SELECT 1
        FROM detalle_evaluacion de
        JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
        WHERE de.id_evaluacion = em.id_evaluacion AND ce.nombre = 'Quizzes y Participación'
    )
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
HAVING 
    promedio_quizzes > 90
    AND COUNT(DISTINCT em.id_camper) >= 5
ORDER BY 
    promedio_quizzes DESC;

-- 18. Consultar la ruta con mayor tasa de graduación
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(DISTINCT CASE WHEN ec.nombre_estado = 'Graduado' THEN c.id_camper END) AS campers_graduados,
    ROUND((COUNT(DISTINCT CASE WHEN ec.nombre_estado = 'Graduado' THEN c.id_camper END) / COUNT(DISTINCT c.id_camper)) * 100, 2) AS tasa_graduacion
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN estado_camper ec ON c.id_estado = ec.id_estado
GROUP BY 
    r.id_ruta, r.nombre
HAVING 
    COUNT(DISTINCT c.id_camper) >= 10 
ORDER BY 
    tasa_graduacion DESC
LIMIT 1;

-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Alto' THEN c.id_camper END) AS campers_riesgo_alto,
    COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Medio' THEN c.id_camper END) AS campers_riesgo_medio,
    ROUND(AVG(em.nota_final), 2) AS promedio_nota
FROM 
    modulo m
JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
JOIN camper c ON em.id_camper = c.id_camper
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nivel_riesgo IN ('Medio', 'Alto')
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
ORDER BY 
    campers_riesgo_alto + campers_riesgo_medio DESC;

-- 20. Obtener la diferencia entre capacidad y ocupación en cada área
SELECT 
    a.nombre AS area,
    s.nombre AS sede,
    a.capacidad_max,
    COUNT(c.id_camper) AS campers_asignados,
    a.capacidad_max - COUNT(c.id_camper) AS diferencia_capacidad,
    CASE
        WHEN COUNT(c.id_camper) > a.capacidad_max THEN 'Sobrecupo'
        WHEN COUNT(c.id_camper) = a.capacidad_max THEN 'Lleno'
        WHEN COUNT(c.id_camper) >= (a.capacidad_max * 0.8) THEN 'Casi lleno'
        WHEN COUNT(c.id_camper) >= (a.capacidad_max * 0.5) THEN 'Medio lleno'
        ELSE 'Disponible'
    END AS estado_ocupacion
FROM 
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
LEFT JOIN grupo g ON a.id_area = g.id_area
LEFT JOIN camper c ON g.id_grupo = c.id_grupo AND c.id_estado = 4 
GROUP BY 
    a.id_area, a.nombre, s.nombre, a.capacidad_max
ORDER BY 
    diferencia_capacidad;