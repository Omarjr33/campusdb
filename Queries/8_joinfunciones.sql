-- 1. Obtener el promedio de nota final por módulo
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_nota,
    MIN(em.nota_final) AS nota_minima,
    MAX(em.nota_final) AS nota_maxima,
    ROUND(STDDEV(em.nota_final), 2) AS desviacion_estandar
FROM 
    modulo m
LEFT JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
ORDER BY 
    promedio_nota DESC;

-- 2. Calcular la cantidad total de campers por ruta
SELECT 
    r.nombre AS ruta,
    COUNT(c.id_camper) AS total_campers,
    COUNT(CASE WHEN ec.nombre_estado = 'Cursando' THEN 1 END) AS campers_activos,
    COUNT(CASE WHEN ec.nombre_estado = 'Graduado' THEN 1 END) AS campers_graduados,
    COUNT(CASE WHEN ec.nombre_estado IN ('Expulsado', 'Retirado') THEN 1 END) AS campers_inactivos
FROM 
    ruta r
LEFT JOIN grupo g ON r.id_ruta = g.id_ruta
LEFT JOIN camper c ON g.id_grupo = c.id_grupo
LEFT JOIN estado_camper ec ON c.id_estado = ec.id_estado
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    total_campers DESC;

-- 3. Mostrar la cantidad de evaluaciones realizadas por cada trainer (según las rutas que imparte)
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT em.id_evaluacion) AS total_evaluaciones,
    COUNT(DISTINCT em.id_camper) AS campers_evaluados,
    COUNT(DISTINCT em.id_modulo) AS modulos_evaluados,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas
FROM 
    trainer t
JOIN trainer_modulo tm ON t.id_trainer = tm.id_trainer
JOIN evaluacion_modulo em ON tm.id_modulo = em.id_modulo AND tm.id_grupo = em.id_grupo
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
ORDER BY 
    total_evaluaciones DESC;

-- 4. Consultar el promedio general de rendimiento por cada área de entrenamiento
SELECT 
    a.nombre AS area,
    s.nombre AS sede,
    h.jornada,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(DISTINCT em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas,
    ROUND((SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS tasa_aprobacion
FROM 
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
JOIN horario h ON a.id_horario = h.id_horario
JOIN grupo g ON a.id_area = g.id_area
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
GROUP BY 
    a.id_area, a.nombre, s.nombre, h.jornada
ORDER BY 
    promedio_notas DESC;

-- 5. Obtener la cantidad de módulos asociados a cada ruta de entrenamiento
SELECT 
    r.nombre AS ruta,
    COUNT(rm.id_modulo) AS total_modulos,
    COUNT(CASE WHEN m.tipo = 'Técnico' THEN 1 END) AS modulos_tecnicos,
    COUNT(CASE WHEN m.tipo = 'Soft Skill' THEN 1 END) AS modulos_soft_skills,
    COUNT(CASE WHEN m.tipo = 'Inglés' THEN 1 END) AS modulos_ingles,
    COUNT(CASE WHEN m.tipo = 'Ser' THEN 1 END) AS modulos_ser,
    SUM(m.duracion_semanas) AS duracion_total_semanas
FROM 
    ruta r
JOIN ruta_modulo rm ON r.id_ruta = rm.id_ruta
JOIN modulo m ON rm.id_modulo = m.id_modulo
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    total_modulos DESC;

-- 6. Mostrar el promedio de nota final de los campers en estado "Cursando"
SELECT 
    ec.nombre_estado,
    ec.nivel_riesgo,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas,
    MIN(em.nota_final) AS nota_minima,
    MAX(em.nota_final) AS nota_maxima,
    ROUND((SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS tasa_aprobacion
FROM 
    estado_camper ec
JOIN camper c ON ec.id_estado = c.id_estado
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
WHERE 
    ec.nombre_estado = 'Cursando'
GROUP BY 
    ec.id_estado, ec.nombre_estado, ec.nivel_riesgo
ORDER BY 
    promedio_notas DESC;

-- 7. Listar el número de campers evaluados en cada módulo
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(DISTINCT em.id_camper) AS campers_evaluados,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas,
    COUNT(CASE WHEN em.estado = 'Aprobado' THEN 1 END) AS aprobados,
    COUNT(CASE WHEN em.estado = 'Reprobado' THEN 1 END) AS reprobados
FROM 
    modulo m
LEFT JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
ORDER BY 
    campers_evaluados DESC;

-- 8. Consultar el porcentaje de ocupación actual por cada área de entrenamiento
SELECT 
    a.nombre AS area,
    s.nombre AS sede,
    h.jornada,
    a.capacidad_max,
    COUNT(c.id_camper) AS campers_asignados,
    ROUND((COUNT(c.id_camper) / a.capacidad_max) * 100, 2) AS porcentaje_ocupacion,
    CASE 
        WHEN COUNT(c.id_camper) > a.capacidad_max THEN 'Sobrecupo'
        WHEN COUNT(c.id_camper) = a.capacidad_max THEN 'Lleno'
        WHEN COUNT(c.id_camper) >= (a.capacidad_max * 0.8) THEN 'Casi lleno'
        ELSE 'Disponible'
    END AS estado_ocupacion
FROM 
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
JOIN horario h ON a.id_horario = h.id_horario
LEFT JOIN grupo g ON a.id_area = g.id_area
LEFT JOIN camper c ON g.id_grupo = c.id_grupo AND c.id_estado = 4 -- Estado 'Cursando'
GROUP BY 
    a.id_area, a.nombre, s.nombre, h.jornada, a.capacidad_max
ORDER BY 
    porcentaje_ocupacion DESC;

-- 9. Mostrar cuántos trainers tiene asignados cada área
SELECT 
    a.nombre AS area,
    s.nombre AS sede,
    h.jornada,
    COUNT(DISTINCT t.id_trainer) AS total_trainers,
    GROUP_CONCAT(DISTINCT CONCAT(t.nombres, ' ', t.apellidos) SEPARATOR ', ') AS trainers
FROM 
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
JOIN horario h ON a.id_horario = h.id_horario
LEFT JOIN grupo g ON a.id_area = g.id_area
LEFT JOIN trainer_grupo tg ON g.id_grupo = tg.id_grupo
LEFT JOIN trainer t ON tg.id_trainer = t.id_trainer
GROUP BY 
    a.id_area, a.nombre, s.nombre, h.jornada
ORDER BY 
    total_trainers DESC;

-- 10. Listar las rutas que tienen más campers en riesgo alto
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Alto' THEN c.id_camper END) AS campers_riesgo_alto,
    ROUND((COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Alto' THEN c.id_camper END) / COUNT(DISTINCT c.id_camper)) * 100, 2) AS porcentaje_riesgo_alto
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN estado_camper ec ON c.id_estado = ec.id_estado
GROUP BY 
    r.id_ruta, r.nombre
HAVING 
    campers_riesgo_alto > 0
ORDER BY 
    campers_riesgo_alto DESC, porcentaje_riesgo_alto DESC;