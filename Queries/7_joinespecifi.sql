-- 1. Listar los campers que han aprobado todos los módulos de su ruta (nota_final >= 60)
WITH CamperModulosAprobados AS (
    SELECT 
        c.id_camper,
        COUNT(DISTINCT em.id_modulo) AS modulos_aprobados
    FROM 
        camper c
    JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
    WHERE 
        em.estado = 'Aprobado'
    GROUP BY 
        c.id_camper
),
CamperTotalModulos AS (
    SELECT 
        c.id_camper,
        g.id_ruta,
        COUNT(DISTINCT rm.id_modulo) AS total_modulos_ruta
    FROM 
        camper c
    JOIN grupo g ON c.id_grupo = g.id_grupo
    JOIN ruta_modulo rm ON g.id_ruta = rm.id_ruta
    GROUP BY 
        c.id_camper, g.id_ruta
)
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    g.nombre AS grupo,
    r.nombre AS ruta,
    ctm.total_modulos_ruta AS modulos_en_ruta,
    cma.modulos_aprobados
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN CamperModulosAprobados cma ON c.id_camper = cma.id_camper
JOIN CamperTotalModulos ctm ON c.id_camper = ctm.id_camper
WHERE 
    cma.modulos_aprobados = ctm.total_modulos_ruta
ORDER BY 
    r.nombre, c.apellidos, c.nombres;

-- 2. Mostrar las rutas que tienen más de 10 campers inscritos actualmente
SELECT 
    r.nombre AS ruta,
    COUNT(c.id_camper) AS total_campers,
    GROUP_CONCAT(DISTINCT g.nombre SEPARATOR ', ') AS grupos
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
WHERE 
    c.id_estado IN (3, 4, 5, 6)
GROUP BY 
    r.id_ruta, r.nombre
HAVING 
    COUNT(c.id_camper) > 10
ORDER BY 
    total_campers DESC;

-- 3. Consultar las áreas que superan el 80% de su capacidad con el número actual de campers asignados
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
    c.id_estado = 4 -- Estado 'Cursando'
GROUP BY 
    a.id_area, a.nombre, s.nombre, a.capacidad_max
HAVING 
    porcentaje_ocupacion > 80
ORDER BY 
    porcentaje_ocupacion DESC;

-- 4. Obtener los trainers que imparten más de una ruta diferente
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
    COUNT(DISTINCT g.id_ruta) > 1
ORDER BY 
    total_rutas DESC;

-- 5. Listar las evaluaciones donde la nota práctica es mayor que la nota teórica
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    m.nombre AS modulo,
    MAX(CASE WHEN ce.nombre = 'Evaluación Teórica' THEN de.nota ELSE NULL END) AS nota_teorica,
    MAX(CASE WHEN ce.nombre = 'Evaluación Práctica' THEN de.nota ELSE NULL END) AS nota_practica,
    em.nota_final,
    em.estado
FROM 
    evaluacion_modulo em
JOIN camper c ON em.id_camper = c.id_camper
JOIN modulo m ON em.id_modulo = m.id_modulo
JOIN detalle_evaluacion de ON em.id_evaluacion = de.id_evaluacion
JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
GROUP BY 
    em.id_evaluacion, c.id_camper, c.nombres, c.apellidos, m.id_modulo, m.nombre, em.nota_final, em.estado
HAVING 
    nota_practica > nota_teorica
ORDER BY 
    (nota_practica - nota_teorica) DESC;

-- 6. Mostrar campers que están en rutas cuyo SGDB principal es MySQL
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    g.nombre AS grupo,
    r.nombre AS ruta,
    bd.nombre AS sgbd_principal
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN base_datos bd ON r.id_ruta = bd.id_ruta
WHERE 
    bd.nombre = 'MySQL'
    AND bd.tipo = 'Principal'
ORDER BY 
    c.apellidos, c.nombres;

-- 7. Obtener los nombres de los módulos donde los campers han tenido bajo rendimiento
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(DISTINCT em.id_camper) AS total_campers,
    SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) AS reprobados,
    ROUND((SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) / COUNT(DISTINCT em.id_camper)) * 100, 2) AS porcentaje_reprobacion,
    ROUND(AVG(em.nota_final), 2) AS promedio_nota
FROM 
    modulo m
JOIN evaluacion_modulo em ON m.id_modulo = em.id_modulo
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
HAVING 
    porcentaje_reprobacion > 20
    AND COUNT(DISTINCT em.id_camper) >= 5
ORDER BY 
    porcentaje_reprobacion DESC;

-- 8. Consultar las rutas con más de 3 módulos asociados
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
HAVING 
    COUNT(DISTINCT rm.id_modulo) > 3
ORDER BY 
    total_modulos DESC;

-- 9. Listar las inscripciones realizadas en los últimos 30 días con sus respectivos campers y rutas
SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    g.nombre AS grupo,
    r.nombre AS ruta,
    c.fecha_registro,
    DATEDIFF(CURRENT_DATE, c.fecha_registro) AS dias_desde_inscripcion
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
WHERE 
    DATEDIFF(CURRENT_DATE, c.fecha_registro) <= 30
ORDER BY 
    c.fecha_registro DESC;

-- 10. Obtener los trainers que están asignados a rutas con campers en estado de "Alto Riesgo"
SELECT DISTINCT
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    r.nombre AS ruta,
    COUNT(DISTINCT CASE WHEN ec.nivel_riesgo = 'Alto' THEN c.id_camper END) AS campers_alto_riesgo
FROM 
    trainer t
JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
JOIN grupo g ON tg.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nivel_riesgo = 'Alto'
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad, r.id_ruta, r.nombre
HAVING 
    campers_alto_riesgo > 0
ORDER BY 
    campers_alto_riesgo DESC;