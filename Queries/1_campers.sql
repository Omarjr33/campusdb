-- 1. Obtener todos los campers inscritos actualmente
SELECT 
    c.id_camper,
    c.num_identificacion,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    g.nombre AS grupo,
    r.nombre AS ruta
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
WHERE 
    c.id_estado IN (2, 3, 4, 5, 6); -- Estados: Inscrito, Aprobado, Cursando (todos los niveles)

-- 2. Listar los campers con estado "Aprobado"
SELECT 
    c.id_camper,
    c.num_identificacion,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    g.nombre AS grupo,
    r.nombre AS ruta
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nombre_estado = 'Aprobado';

-- 3. Mostrar los campers que ya están cursando alguna ruta
SELECT 
    c.id_camper,
    c.num_identificacion,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    g.nombre AS grupo,
    r.nombre AS ruta,
    ec.nombre_estado,
    ec.nivel_riesgo
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nombre_estado = 'Cursando';

-- 4. Consultar los campers graduados por cada ruta
SELECT 
    r.nombre AS ruta,
    COUNT(c.id_camper) AS total_graduados,
    GROUP_CONCAT(CONCAT(c.nombres, ' ', c.apellidos) SEPARATOR ', ') AS campers_graduados
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nombre_estado = 'Graduado'
GROUP BY 
    r.id_ruta, r.nombre;

-- 5. Obtener los campers que se encuentran en estado "Expulsado" o "Retirado"
SELECT 
    c.id_camper,
    c.num_identificacion,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    ec.nombre_estado,
    c.fecha_registro,
    DATEDIFF(CURRENT_DATE, c.fecha_registro) AS dias_desde_registro
FROM 
    camper c
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nombre_estado IN ('Expulsado', 'Retirado');

-- 6. Listar campers con nivel de riesgo "Alto"
SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    g.nombre AS grupo,
    r.nombre AS ruta,
    ec.nombre_estado,
    ec.nivel_riesgo
FROM 
    camper c
JOIN grupo g ON c.id_grupo = g.id_grupo
JOIN ruta r ON g.id_ruta = r.id_ruta
JOIN estado_camper ec ON c.id_estado = ec.id_estado
WHERE 
    ec.nivel_riesgo = 'Alto';

-- 7. Mostrar el total de campers por cada nivel de riesgo
SELECT 
    ec.nivel_riesgo,
    COUNT(c.id_camper) AS total_campers,
    ROUND((COUNT(c.id_camper) / (SELECT COUNT(*) FROM camper)) * 100, 2) AS porcentaje
FROM 
    camper c
JOIN estado_camper ec ON c.id_estado = ec.id_estado
GROUP BY 
    ec.nivel_riesgo
ORDER BY 
    total_campers DESC;

-- 8. Obtener campers con más de un número telefónico registrado (simulación)
SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    c.telefono AS telefono_principal,
    CONCAT('3', LPAD(FLOOR(RAND() * 10000000), 9, '0')) AS telefono_adicional
FROM 
    camper c
WHERE 
    LENGTH(c.telefono) > 0
    AND RIGHT(c.id_camper, 1) IN ('1', '3', '5', '7', '9'); 

-- 9. Listar los campers y sus respectivos acudientes y teléfonos
SELECT 
    c.id_camper,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    c.acudiente,
    c.telefono AS telefono_contacto
FROM 
    camper c
WHERE 
    c.acudiente IS NOT NULL
ORDER BY 
    c.apellidos, c.nombres;

-- 10. Mostrar campers que aún no han sido asignados a una ruta
SELECT 
    c.id_camper,
    c.num_identificacion,
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    ec.nombre_estado,
    s.nombre AS sede
FROM 
    camper c
JOIN estado_camper ec ON c.id_estado = ec.id_estado
JOIN sede s ON c.id_sede = s.id_sede
WHERE 
    c.id_grupo IS NULL;
