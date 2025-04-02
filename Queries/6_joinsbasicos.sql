-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos
SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    g.nombre AS grupo,
    r.nombre AS ruta
FROM 
    camper c
INNER JOIN grupo g ON c.id_grupo = g.id_grupo
INNER JOIN ruta r ON g.id_ruta = r.id_ruta
ORDER BY 
    c.apellidos, c.nombres;

-- 2. Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    m.nombre AS modulo,
    MAX(CASE WHEN ce.nombre = 'Evaluación Teórica' THEN de.nota ELSE NULL END) AS nota_teorica,
    MAX(CASE WHEN ce.nombre = 'Evaluación Práctica' THEN de.nota ELSE NULL END) AS nota_practica,
    MAX(CASE WHEN ce.nombre = 'Quizzes y Participación' THEN de.nota ELSE NULL END) AS nota_quizzes,
    em.nota_final,
    em.estado
FROM 
    camper c
INNER JOIN evaluacion_modulo em ON c.id_camper = em.id_camper
INNER JOIN modulo m ON em.id_modulo = m.id_modulo
INNER JOIN detalle_evaluacion de ON em.id_evaluacion = de.id_evaluacion
INNER JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
GROUP BY 
    c.id_camper, m.id_modulo, em.id_evaluacion
ORDER BY 
    c.apellidos, c.nombres, m.nombre;

-- 3. Listar todos los módulos que componen cada ruta de entrenamiento
SELECT 
    r.nombre AS ruta,
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    m.duracion_semanas,
    rm.orden AS orden_en_ruta
FROM 
    ruta r
INNER JOIN ruta_modulo rm ON r.id_ruta = rm.id_ruta
INNER JOIN modulo m ON rm.id_modulo = m.id_modulo
ORDER BY 
    r.nombre, rm.orden;

-- 4. Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases
SELECT 
    r.nombre AS ruta,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    a.nombre AS area,
    s.nombre AS sede,
    h.jornada
FROM 
    ruta r
INNER JOIN grupo g ON r.id_ruta = g.id_ruta
INNER JOIN trainer_grupo tg ON g.id_grupo = tg.id_grupo
INNER JOIN trainer t ON tg.id_trainer = t.id_trainer
INNER JOIN area_entrenamiento a ON g.id_area = a.id_area
INNER JOIN sede s ON a.id_sede = s.id_sede
INNER JOIN horario h ON a.id_horario = h.id_horario
ORDER BY 
    r.nombre, a.nombre;

-- 5. Mostrar los campers junto con el trainer responsable de su ruta actual
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    g.nombre AS grupo,
    r.nombre AS ruta,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad
FROM 
    camper c
INNER JOIN grupo g ON c.id_grupo = g.id_grupo
INNER JOIN ruta r ON g.id_ruta = r.id_ruta
INNER JOIN trainer_grupo tg ON g.id_grupo = tg.id_grupo
INNER JOIN trainer t ON tg.id_trainer = t.id_trainer
ORDER BY 
    c.apellidos, c.nombres;

-- 6. Obtener el listado de evaluaciones realizadas con nombre de camper, módulo y ruta
SELECT 
    em.id_evaluacion,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_camper,
    m.nombre AS modulo,
    g.nombre AS grupo,
    r.nombre AS ruta,
    em.nota_final,
    em.estado,
    em.fecha_evaluacion
FROM 
    evaluacion_modulo em
INNER JOIN camper c ON em.id_camper = c.id_camper
INNER JOIN modulo m ON em.id_modulo = m.id_modulo
INNER JOIN grupo g ON em.id_grupo = g.id_grupo
INNER JOIN ruta r ON g.id_ruta = r.id_ruta
ORDER BY 
    em.fecha_evaluacion DESC, c.apellidos, c.nombres;

-- 7. Listar los trainers y los horarios en que están asignados a las áreas de entrenamiento
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    g.nombre AS grupo,
    a.nombre AS area,
    s.nombre AS sede,
    h.jornada,
    CONCAT(h.hora_inicio, ' - ', h.hora_fin) AS horario
FROM 
    trainer t
INNER JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
INNER JOIN grupo g ON tg.id_grupo = g.id_grupo
INNER JOIN area_entrenamiento a ON g.id_area = a.id_area
INNER JOIN sede s ON a.id_sede = s.id_sede
INNER JOIN horario h ON a.id_horario = h.id_horario
ORDER BY 
    t.apellidos, t.nombres, h.jornada;


SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    ec.nombre_estado,
    ec.nivel_riesgo,
    s.nombre AS sede,
    g.nombre AS grupo,
    r.nombre AS ruta
FROM 
    camper c
INNER JOIN estado_camper ec ON c.id_estado = ec.id_estado
INNER JOIN sede s ON c.id_sede = s.id_sede
LEFT JOIN grupo g ON c.id_grupo = g.id_grupo
LEFT JOIN ruta r ON g.id_ruta = r.id_ruta
ORDER BY 
    ec.nivel_riesgo DESC, c.apellidos, c.nombres;

-- 9. Obtener todos los módulos de cada ruta junto con su porcentaje teórico, práctico y de quizzes
SELECT 
    r.nombre AS ruta,
    m.nombre AS modulo,
    MAX(CASE WHEN ce.nombre = 'Evaluación Teórica' THEN ce.porcentaje ELSE NULL END) AS porcentaje_teorico,
    MAX(CASE WHEN ce.nombre = 'Evaluación Práctica' THEN ce.porcentaje ELSE NULL END) AS porcentaje_practico,
    MAX(CASE WHEN ce.nombre = 'Quizzes y Participación' THEN ce.porcentaje ELSE NULL END) AS porcentaje_quizzes
FROM 
    ruta r
INNER JOIN ruta_modulo rm ON r.id_ruta = rm.id_ruta
INNER JOIN modulo m ON rm.id_modulo = m.id_modulo
LEFT JOIN criterio_evaluacion ce ON m.id_modulo = ce.id_modulo
GROUP BY 
    r.id_ruta, r.nombre, m.id_modulo, m.nombre
ORDER BY 
    r.nombre, rm.orden;

-- 10. Mostrar los nombres de las áreas junto con los nombres de los campers que están asistiendo en esos espacios
SELECT 
    a.nombre AS area,
    s.nombre AS sede,
    h.jornada,
    COUNT(c.id_camper) AS total_campers,
    GROUP_CONCAT(DISTINCT CONCAT(c.nombres, ' ', c.apellidos) SEPARATOR ', ') AS campers
FROM 
    area_entrenamiento a
INNER JOIN sede s ON a.id_sede = s.id_sede
INNER JOIN horario h ON a.id_horario = h.id_horario
LEFT JOIN grupo g ON a.id_area = g.id_area
LEFT JOIN camper c ON g.id_grupo = c.id_grupo AND c.id_estado = 4 -- Estado 'Cursando'
GROUP BY 
    a.id_area, a.nombre, s.nombre, h.jornada
ORDER BY 
    total_campers DESC;