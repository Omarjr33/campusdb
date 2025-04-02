-- 1. Mostrar todas las rutas de entrenamiento disponibles
SELECT 
    r.id_ruta,
    r.nombre,
    r.descripcion,
    r.duracion_meses,
    COUNT(DISTINCT rm.id_modulo) AS total_modulos,
    COUNT(DISTINCT c.id_camper) AS total_campers
FROM 
    ruta r
LEFT JOIN ruta_modulo rm ON r.id_ruta = rm.id_ruta
LEFT JOIN grupo g ON r.id_ruta = g.id_ruta
LEFT JOIN camper c ON g.id_grupo = c.id_grupo
GROUP BY 
    r.id_ruta, r.nombre, r.descripcion, r.duracion_meses
ORDER BY 
    total_campers DESC;

-- 2. Obtener las rutas con su SGDB principal y alternativo
SELECT 
    r.nombre AS ruta,
    MAX(CASE WHEN bd.tipo = 'Principal' THEN bd.nombre ELSE NULL END) AS sgbd_principal,
    MAX(CASE WHEN bd.tipo = 'Alternativo' THEN bd.nombre ELSE NULL END) AS sgbd_alternativo
FROM 
    ruta r
LEFT JOIN base_datos bd ON r.id_ruta = bd.id_ruta
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    r.nombre;

-- 3. Listar los módulos asociados a cada ruta
SELECT 
    r.nombre AS ruta,
    m.nombre AS modulo,
    m.tipo AS tipo_modulo,
    m.duracion_semanas,
    rm.orden AS orden_en_ruta
FROM 
    ruta r
JOIN ruta_modulo rm ON r.id_ruta = rm.id_ruta
JOIN modulo m ON rm.id_modulo = m.id_modulo
ORDER BY 
    r.nombre, rm.orden;

-- 4. Consultar cuántos campers hay en cada ruta
SELECT 
    r.nombre AS ruta,
    COUNT(c.id_camper) AS total_campers,
    GROUP_CONCAT(DISTINCT g.nombre SEPARATOR ', ') AS grupos
FROM 
    ruta r
LEFT JOIN grupo g ON r.id_ruta = g.id_ruta
LEFT JOIN camper c ON g.id_grupo = c.id_grupo
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    total_campers DESC;

-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima
SELECT
    a.nombre AS area,
    a.capacidad_max,
    COUNT(c.id_camper) AS campers_asignados,
    ROUND((COUNT(c.id_camper) / a.capacidad_max) * 100, 2) AS porcentaje_ocupacion,
    s.nombre AS sede
FROM
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
JOIN grupo g ON a.id_area = g.id_area
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE
    ec.nombre_estado = 'Cursando'
GROUP BY
    a.id_area, a.nombre, a.capacidad_max, s.nombre
ORDER BY
    porcentaje_ocupacion DESC;

-- 6. Obtener las áreas que están ocupadas al 100%
SELECT 
    a.nombre AS area,
    a.capacidad_max,
    COUNT(c.id_camper) AS campers_asignados,
    ROUND((COUNT(c.id_camper) / a.capacidad_max) * 100, 2) AS porcentaje_ocupacion,
    s.nombre AS sede
FROM 
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
JOIN grupo g ON a.id_area = g.id_area
JOIN camper c ON g.id_grupo = c.id_grupo
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nombre_estado = 'Cursando'
GROUP BY 
    a.id_area, a.nombre, a.capacidad_max, s.nombre
HAVING 
    COUNT(c.id_camper) >= a.capacidad_max
ORDER BY 
    porcentaje_ocupacion DESC;

-- 7. Verificar la ocupación actual de cada área
SELECT 
    a.nombre AS area,
    a.capacidad_max,
    COUNT(c.id_camper) AS campers_asignados,
    a.capacidad_max - COUNT(c.id_camper) AS lugares_disponibles,
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
LEFT JOIN grupo g ON a.id_area = g.id_area
LEFT JOIN camper c ON g.id_grupo = c.id_grupo AND c.id_estado = 4 
GROUP BY 
    a.id_area, a.nombre, a.capacidad_max, s.nombre
ORDER BY 
    porcentaje_ocupacion DESC;

-- 8. Consultar los horarios disponibles por cada área
SELECT 
    h.jornada,
    CONCAT(h.hora_inicio, ' - ', h.hora_fin) AS horario,
    COUNT(a.id_area) AS areas_asignadas,
    GROUP_CONCAT(DISTINCT a.nombre SEPARATOR ', ') AS areas,
    GROUP_CONCAT(DISTINCT s.nombre SEPARATOR ', ') AS sedes
FROM 
    horario h
LEFT JOIN area_entrenamiento a ON h.id_horario = a.id_horario
LEFT JOIN sede s ON a.id_sede = s.id_sede
GROUP BY 
    h.id_horario, h.jornada, h.hora_inicio, h.hora_fin
ORDER BY 
    h.jornada, h.hora_inicio;

-- 9. Mostrar las áreas con más campers asignados
SELECT 
    a.nombre AS area,
    s.nombre AS sede,
    h.jornada,
    COUNT(c.id_camper) AS total_campers,
    a.capacidad_max,
    ROUND((COUNT(c.id_camper) / a.capacidad_max) * 100, 2) AS porcentaje_ocupacion
FROM 
    area_entrenamiento a
JOIN sede s ON a.id_sede = s.id_sede
JOIN horario h ON a.id_horario = h.id_horario
LEFT JOIN grupo g ON a.id_area = g.id_area
LEFT JOIN camper c ON g.id_grupo = c.id_grupo AND c.id_estado = 4 
GROUP BY 
    a.id_area, a.nombre, s.nombre, h.jornada, a.capacidad_max
ORDER BY 
    total_campers DESC;

-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.id_camper) AS total_campers,
    GROUP_CONCAT(DISTINCT CONCAT(t.nombres, ' ', t.apellidos) SEPARATOR ', ') AS trainers,
    GROUP_CONCAT(DISTINCT a.nombre SEPARATOR ', ') AS areas,
    GROUP_CONCAT(DISTINCT s.nombre SEPARATOR ', ') AS sedes
FROM 
    ruta r
JOIN grupo g ON r.id_ruta = g.id_ruta
JOIN area_entrenamiento a ON g.id_area = a.id_area
JOIN sede s ON a.id_sede = s.id_sede
LEFT JOIN trainer_grupo tg ON g.id_grupo = tg.id_grupo
LEFT JOIN trainer t ON tg.id_trainer = t.id_trainer
LEFT JOIN camper c ON g.id_grupo = c.id_grupo
GROUP BY 
    r.id_ruta, r.nombre
ORDER BY 
    total_campers DESC;