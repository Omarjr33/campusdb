-- 1. Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    m.nombre AS modulo,
    g.nombre AS grupo,
    MAX(CASE WHEN ce.nombre = 'Evaluación Teórica' THEN de.nota ELSE NULL END) AS nota_teorica,
    MAX(CASE WHEN ce.nombre = 'Evaluación Práctica' THEN de.nota ELSE NULL END) AS nota_practica,
    MAX(CASE WHEN ce.nombre = 'Quizzes y Participación' THEN de.nota ELSE NULL END) AS nota_quizzes,
    em.nota_final
FROM 
    evaluacion_modulo em
JOIN camper c ON em.id_camper = c.id_camper
JOIN modulo m ON em.id_modulo = m.id_modulo
JOIN grupo g ON em.id_grupo = g.id_grupo
JOIN detalle_evaluacion de ON em.id_evaluacion = de.id_evaluacion
JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
GROUP BY 
    em.id_evaluacion, c.id_camper, m.id_modulo, g.id_grupo
ORDER BY 
    c.apellidos, c.nombres, m.nombre;

-- 2. Calcular la nota final de cada camper por módulo
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    m.nombre AS modulo,
    g.nombre AS grupo,
    ROUND(SUM(de.nota * ce.porcentaje / 100), 2) AS nota_final_calculada,
    em.nota_final AS nota_final_registrada,
    em.estado
FROM 
    evaluacion_modulo em
JOIN camper c ON em.id_camper = c.id_camper
JOIN modulo m ON em.id_modulo = m.id_modulo
JOIN grupo g ON em.id_grupo = g.id_grupo
JOIN detalle_evaluacion de ON em.id_evaluacion = de.id_evaluacion
JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
GROUP BY 
    em.id_evaluacion, c.id_camper, m.id_modulo, g.id_grupo
ORDER BY 
    nota_final_calculada DESC;

-- 3. Mostrar los campers que reprobaron algún módulo (nota < 60)
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    m.nombre AS modulo,
    g.nombre AS grupo,
    r.nombre AS ruta,
    em.nota_final,
    em.estado
FROM 
    evaluacion_modulo em
JOIN camper c ON em.id_camper = c.id_camper
JOIN modulo m ON em.id_modulo = m.id_modulo
JOIN grupo g ON em.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
WHERE 
    em.estado = 'Reprobado'
ORDER BY 
    em.nota_final;

-- 4. Listar los módulos con más campers en bajo rendimiento
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) AS reprobados,
    ROUND((SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS porcentaje_reprobacion
FROM 
    evaluacion_modulo em
JOIN modulo m ON em.id_modulo = m.id_modulo
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
HAVING 
    COUNT(em.id_evaluacion) > 0
ORDER BY 
    porcentaje_reprobacion DESC;

-- 5. Obtener el promedio de notas finales por cada módulo
SELECT 
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_nota,
    MIN(em.nota_final) AS nota_minima,
    MAX(em.nota_final) AS nota_maxima
FROM 
    evaluacion_modulo em
JOIN modulo m ON em.id_modulo = m.id_modulo
GROUP BY 
    m.id_modulo, m.nombre, m.tipo
HAVING 
    COUNT(em.id_evaluacion) > 0
ORDER BY 
    promedio_nota DESC;

-- 6. Consultar el rendimiento general por ruta de entrenamiento
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_general,
    SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) AS evaluaciones_aprobadas,
    SUM(CASE WHEN em.estado = 'Reprobado' THEN 1 ELSE 0 END) AS evaluaciones_reprobadas,
    ROUND((SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS porcentaje_aprobacion
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    promedio_general DESC;

-- 7. Mostrar los trainers responsables de campers con bajo rendimiento
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(DISTINCT CASE WHEN em.estado = 'Reprobado' THEN c.id_camper END) AS campers_reprobados,
    ROUND((COUNT(DISTINCT CASE WHEN em.estado = 'Reprobado' THEN c.id_camper END) / COUNT(DISTINCT c.id_camper)) * 100, 2) AS porcentaje_reprobacion
FROM 
    trainer t
JOIN trainer_modulo tm ON t.id_trainer = tm.id_trainer
JOIN evaluacion_modulo em ON tm.id_modulo = em.id_modulo AND tm.id_grupo = em.id_grupo
JOIN camper c ON em.id_camper = c.id_camper
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
HAVING 
    COUNT(DISTINCT CASE WHEN em.estado = 'Reprobado' THEN c.id_camper END) > 0
ORDER BY 
    porcentaje_reprobacion DESC;

-- 8. Comparar el promedio de rendimiento por trainer
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas,
    (
        SELECT ROUND(AVG(em2.nota_final), 2)
        FROM evaluacion_modulo em2
    ) AS promedio_global,
    ROUND(AVG(em.nota_final) - (
        SELECT AVG(em2.nota_final)
        FROM evaluacion_modulo em2
    ), 2) AS diferencia_con_promedio
FROM 
    trainer t
JOIN trainer_modulo tm ON t.id_trainer = tm.id_trainer
JOIN evaluacion_modulo em ON tm.id_modulo = em.id_modulo AND tm.id_grupo = em.id_grupo
JOIN camper c ON em.id_camper = c.id_camper
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
HAVING 
    COUNT(em.id_evaluacion) > 0
ORDER BY 
    promedio_notas DESC;

-- 9. Listar los mejores 5 campers por nota final en cada ruta
WITH RankedCampers AS (
    SELECT 
        r.id_ruta,
        r.nombre AS ruta,
        c.id_camper,
        CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
        AVG(em.nota_final) AS promedio_notas,
        RANK() OVER (PARTITION BY r.id_ruta ORDER BY AVG(em.nota_final) DESC) AS ranking
    FROM 
        ruta r
    JOIN grupo g ON r.id_ruta = g.id_ruta
    JOIN camper c ON g.id_grupo = c.id_grupo
    JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
    GROUP BY 
        r.id_ruta, r.nombre, c.id_camper, c.nombres, c.apellidos
)
SELECT 
    ruta,
    nombre_completo,
    promedio_notas,
    ranking
FROM 
    RankedCampers
WHERE 
    ranking <= 5
ORDER BY 
    id_ruta, ranking;

-- 10. Mostrar cuántos campers pasaron cada módulo por ruta
SELECT 
    r.nombre AS ruta,
    m.nombre AS modulo,
    COUNT(em.id_evaluacion) AS total_evaluaciones,
    SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) AS campers_aprobados,
    ROUND((SUM(CASE WHEN em.estado = 'Aprobado' THEN 1 ELSE 0 END) / COUNT(em.id_evaluacion)) * 100, 2) AS porcentaje_aprobacion
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
JOIN modulo m ON em.id_modulo = m.id_modulo
GROUP BY 
    r.id_ruta, r.nombre, m.id_modulo, m.nombre
ORDER BY 
    r.nombre, porcentaje_aprobacion DESC;