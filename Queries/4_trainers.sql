-- 1. Listar todos los entrenadores registrados
SELECT 
    t.id_trainer,
    t.num_identificacion,
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_completo,
    t.especialidad,
    t.email,
    t.telefono,
    s.nombre AS sede,
    ci.nombre AS ciudad
FROM 
    trainer t
JOIN sede s ON t.id_sede = s.id_sede
JOIN ciudad ci ON s.id_ciudad = ci.id_ciudad
ORDER BY 
    t.apellidos, t.nombres;

-- 2. Mostrar los trainers con sus horarios asignados
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    g.nombre AS grupo,
    a.nombre AS area,
    h.jornada,
    CONCAT(h.hora_inicio, ' - ', h.hora_fin) AS horario
FROM 
    trainer t
JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
JOIN grupo g ON tg.id_grupo = g.id_grupo
JOIN area_entrenamiento a ON g.id_area = a.id_area
JOIN horario h ON a.id_horario = h.id_horario
ORDER BY 
    t.apellidos, t.nombres, h.jornada;

-- 3. Consultar los trainers asignados a más de una ruta
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

-- 4. Obtener el número de campers por trainer
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    GROUP_CONCAT(DISTINCT g.nombre SEPARATOR ', ') AS grupos
FROM 
    trainer t
JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
JOIN grupo g ON tg.id_grupo = g.id_grupo
JOIN camper c ON g.id_grupo = c.id_grupo
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
ORDER BY 
    total_campers DESC;

-- 5. Mostrar las áreas en las que trabaja cada trainer
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    COUNT(DISTINCT a.id_area) AS total_areas,
    GROUP_CONCAT(DISTINCT a.nombre SEPARATOR ', ') AS areas,
    GROUP_CONCAT(DISTINCT CONCAT(s.nombre, ' (', h.jornada, ')') SEPARATOR ', ') AS sedes_horarios
FROM 
    trainer t
JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
JOIN grupo g ON tg.id_grupo = g.id_grupo
JOIN area_entrenamiento a ON g.id_area = a.id_area
JOIN sede s ON a.id_sede = s.id_sede
JOIN horario h ON a.id_horario = h.id_horario
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos
ORDER BY 
    total_areas DESC;

-- 6. Listar los trainers sin asignación de área o ruta
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    t.email,
    s.nombre AS sede
FROM 
    trainer t
JOIN sede s ON t.id_sede = s.id_sede
LEFT JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
WHERE 
    tg.id_trainer_grupo IS NULL;

-- 7. Mostrar cuántos módulos están a cargo de cada trainer
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT tm.id_modulo) AS total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre SEPARATOR ', ') AS modulos
FROM 
    trainer t
JOIN trainer_modulo tm ON t.id_trainer = tm.id_trainer
JOIN modulo m ON tm.id_modulo = m.id_modulo
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
ORDER BY 
    total_modulos DESC;

SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    t.especialidad,
    COUNT(DISTINCT em.id_camper) AS total_campers_evaluados,
    ROUND(AVG(em.nota_final), 2) AS promedio_notas,
    MIN(em.nota_final) AS nota_minima,
    MAX(em.nota_final) AS nota_maxima,
    COUNT(DISTINCT CASE WHEN em.estado = 'Aprobado' THEN em.id_camper END) AS campers_aprobados,
    ROUND((COUNT(DISTINCT CASE WHEN em.estado = 'Aprobado' THEN em.id_camper END) / COUNT(DISTINCT em.id_camper)) * 100, 2) AS tasa_aprobacion
FROM 
    trainer t
JOIN trainer_modulo tm ON t.id_trainer = tm.id_trainer
JOIN evaluacion_modulo em ON tm.id_modulo = em.id_modulo AND tm.id_grupo = em.id_grupo
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, t.especialidad
HAVING 
    COUNT(DISTINCT em.id_camper) >= 5  
ORDER BY 
    promedio_notas DESC
LIMIT 1;

-- 9. Consultar los horarios ocupados por cada trainer
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    h.jornada,
    CONCAT(h.hora_inicio, ' - ', h.hora_fin) AS horario,
    GROUP_CONCAT(DISTINCT g.nombre SEPARATOR ', ') AS grupos,
    GROUP_CONCAT(DISTINCT a.nombre SEPARATOR ', ') AS areas
FROM 
    trainer t
JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
JOIN grupo g ON tg.id_grupo = g.id_grupo
JOIN area_entrenamiento a ON g.id_area = a.id_area
JOIN horario h ON a.id_horario = h.id_horario
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos, h.id_horario, h.jornada, h.hora_inicio, h.hora_fin
ORDER BY 
    t.apellidos, t.nombres, h.jornada;

-- 10. Mostrar la disponibilidad semanal de cada trainer
SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) AS nombre_trainer,
    MAX(CASE WHEN h.jornada = 'Mañana' THEN 'Ocupado' ELSE 'Disponible' END) AS disponibilidad_manana,
    MAX(CASE WHEN h.jornada = 'Tarde' THEN 'Ocupado' ELSE 'Disponible' END) AS disponibilidad_tarde,
    GROUP_CONCAT(DISTINCT g.nombre SEPARATOR ', ') AS grupos_asignados
FROM 
    trainer t
LEFT JOIN trainer_grupo tg ON t.id_trainer = tg.id_trainer
LEFT JOIN grupo g ON tg.id_grupo = g.id_grupo
LEFT JOIN area_entrenamiento a ON g.id_area = a.id_area
LEFT JOIN horario h ON a.id_horario = h.id_horario
GROUP BY 
    t.id_trainer, t.nombres, t.apellidos
ORDER BY 
    t.apellidos, t.nombres;