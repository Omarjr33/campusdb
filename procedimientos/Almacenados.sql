DELIMITER $$

-- 1. Registrar un nuevo camper con toda su información personal y estado inicial.
CREATE PROCEDURE sp_registrar_camper(
    IN p_num_identificacion VARCHAR(50),
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_direccion VARCHAR(255),
    IN p_accidente VARCHAR(255),
    IN p_telefono VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_acudiente VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_id_estado INT,
    IN p_id_grupo INT,
    IN p_id_sede INT,
    IN p_fecha_registro DATE
)
BEGIN
    INSERT INTO camper(num_identificacion, nombres, apellidos, direccion, accidente, telefono, email, acudiente, fecha_nacimiento, id_estado, id_grupo, id_sede, fecha_registro)
    VALUES (p_num_identificacion, p_nombres, p_apellidos, p_direccion, p_accidente, p_telefono, p_email, p_acudiente, p_fecha_nacimiento, p_id_estado, p_id_grupo, p_id_sede, p_fecha_registro);
END$$

-- 2. Actualizar el estado de un camper luego de completar el proceso de ingreso.
CREATE PROCEDURE sp_actualizar_estado_camper(
    IN p_id_camper INT,
    IN p_nuevo_estado INT
)
BEGIN
    UPDATE camper
    SET id_estado = p_nuevo_estado
    WHERE id_camper = p_id_camper;
END$$

-- 3. Procesar la inscripción de un camper a una ruta específica.
CREATE PROCEDURE sp_inscribir_camper(
    IN p_id_camper INT,
    IN p_id_grupo INT
)
BEGIN
    UPDATE camper
    SET id_grupo = p_id_grupo,
        id_estado = 2  -- Estado "Inscrito"
    WHERE id_camper = p_id_camper;
END$$

-- 4. Registrar una evaluación completa (teórica, práctica y quizzes) para un camper.
CREATE PROCEDURE sp_registrar_evaluacion_camper(
    IN p_id_camper INT,
    IN p_id_modulo INT,
    IN p_id_grupo INT,
    IN p_nota_final DECIMAL(5,2),
    IN p_estado VARCHAR(50),
    IN p_fecha_evaluacion DATE,
    IN p_nota_teorica DECIMAL(5,2),
    IN p_nota_practica DECIMAL(5,2),
    IN p_nota_quizzes DECIMAL(5,2)
)
BEGIN
    DECLARE eval_id INT;
    -- Inserta la evaluación general
    INSERT INTO evaluacion_modulo(id_camper, id_modulo, id_grupo, nota_final, estado, fecha_evaluacion)
    VALUES (p_id_camper, p_id_modulo, p_id_grupo, p_nota_final, p_estado, p_fecha_evaluacion);
    SET eval_id = LAST_INSERT_ID();
    -- Se determinan los criterios de evaluación (asumiendo que ya existen para el módulo)
    DECLARE id_teorica INT;
    DECLARE id_practica INT;
    DECLARE id_quizzes INT;
    SELECT id_criterio INTO id_teorica FROM criterio_evaluacion WHERE id_modulo = p_id_modulo AND nombre LIKE '%Teórica%' LIMIT 1;
    SELECT id_criterio INTO id_practica FROM criterio_evaluacion WHERE id_modulo = p_id_modulo AND nombre LIKE '%Práctica%' LIMIT 1;
    SELECT id_criterio INTO id_quizzes FROM criterio_evaluacion WHERE id_modulo = p_id_modulo AND nombre LIKE '%Quizzes%' LIMIT 1;
    -- Inserta los detalles de evaluación
    INSERT INTO detalle_evaluacion (id_evaluacion, id_criterio, nota, comentario)
      VALUES (eval_id, id_teorica, p_nota_teorica, 'Evaluación teórica registrada');
    INSERT INTO detalle_evaluacion (id_evaluacion, id_criterio, nota, comentario)
      VALUES (eval_id, id_practica, p_nota_practica, 'Evaluación práctica registrada');
    INSERT INTO detalle_evaluacion (id_evaluacion, id_criterio, nota, comentario)
      VALUES (eval_id, id_quizzes, p_nota_quizzes, 'Evaluación de quizzes registrada');
END$$

-- 5. Calcular y registrar automáticamente la nota final de un módulo.
CREATE PROCEDURE sp_calcular_nota_final(
    IN p_id_evaluacion INT
)
BEGIN
    DECLARE final DECIMAL(5,2);
    SELECT ROUND(SUM(de.nota * ce.porcentaje / 100), 2)
      INTO final
    FROM detalle_evaluacion de
    JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
    WHERE de.id_evaluacion = p_id_evaluacion;
    UPDATE evaluacion_modulo
    SET nota_final = final
    WHERE id_evaluacion = p_id_evaluacion;
END$$

-- 6. Asignar campers aprobados a una ruta de acuerdo con la disponibilidad del área.
CREATE PROCEDURE sp_asignar_camper_ruta(
    IN p_id_camper INT,
    IN p_id_grupo INT
)
BEGIN
    DECLARE area_cap INT;
    DECLARE campers_count INT;
    DECLARE area_id INT;
    
    SELECT id_area INTO area_id FROM grupo WHERE id_grupo = p_id_grupo;
    SELECT capacidad_max INTO area_cap FROM area_entrenamiento WHERE id_area = area_id;
    SELECT COUNT(*) INTO campers_count
      FROM grupo g
      JOIN camper c ON g.id_grupo = c.id_grupo
      WHERE g.id_area = area_id AND c.id_estado = 4;
    IF campers_count < area_cap THEN
         UPDATE camper
         SET id_grupo = p_id_grupo
         WHERE id_camper = p_id_camper;
    ELSE
         SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT = 'No hay cupos disponibles en el área';
    END IF;
END$$

-- 7. Asignar un trainer a una ruta y área específica, validando que pertenezcan a la misma sede.
CREATE PROCEDURE sp_asignar_trainer(
    IN p_id_trainer INT,
    IN p_id_grupo INT
)
BEGIN
    DECLARE sede_trainer INT;
    DECLARE sede_area INT;
    SELECT id_sede INTO sede_trainer FROM trainer WHERE id_trainer = p_id_trainer;
    SELECT s.id_sede INTO sede_area
      FROM grupo g
      JOIN area_entrenamiento a ON g.id_area = a.id_area
      JOIN sede s ON a.id_sede = s.id_sede
      WHERE g.id_grupo = p_id_grupo;
    IF sede_trainer = sede_area THEN
         INSERT INTO trainer_grupo (id_trainer, id_grupo, fecha_asignacion)
         VALUES (p_id_trainer, p_id_grupo, CURDATE());
    ELSE
         SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT = 'El trainer y el grupo no pertenecen a la misma sede';
    END IF;
END$$

-- 8. Registrar una nueva ruta con sus módulos y SGDB asociados.
CREATE PROCEDURE sp_registrar_ruta(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_duracion INT
)
BEGIN
    DECLARE new_id INT;
    INSERT INTO ruta(nombre, descripcion, duracion_meses)
    VALUES (p_nombre, p_descripcion, p_duracion);
    SET new_id = LAST_INSERT_ID();
    -- Asigna dos módulos por defecto (por ejemplo, los módulos 1 y 2)
    INSERT INTO ruta_modulo (id_ruta, id_modulo, orden) VALUES (new_id, 1, 1), (new_id, 2, 2);
    -- Registrar SGDB asociados (MySQL y PostgreSQL)
    INSERT INTO base_datos (nombre, tipo, id_ruta) VALUES ('MySQL', 'Principal', new_id), ('PostgreSQL', 'Alternativo', new_id);
END$$

-- 9. Registrar una nueva área de entrenamiento con su capacidad y horarios.
CREATE PROCEDURE sp_registrar_area(
    IN p_nombre VARCHAR(100),
    IN p_capacidad INT,
    IN p_ubicacion VARCHAR(255),
    IN p_id_sede INT,
    IN p_id_horario INT
)
BEGIN
    INSERT INTO area_entrenamiento(nombre, capacidad_max, ubicacion, id_sede, id_horario)
    VALUES (p_nombre, p_capacidad, p_ubicacion, p_id_sede, p_id_horario);
END$$

-- 10. Consultar disponibilidad de horario en un área determinada.
CREATE PROCEDURE sp_consultar_disponibilidad_area(
    IN p_id_area INT
)
BEGIN
    DECLARE cap INT;
    DECLARE ocupado INT;
    SELECT capacidad_max INTO cap FROM area_entrenamiento WHERE id_area = p_id_area;
    SELECT COUNT(*) INTO ocupado
      FROM grupo g JOIN camper c ON g.id_grupo = c.id_grupo
      WHERE g.id_area = p_id_area AND c.id_estado = 4;
    SELECT p_id_area AS area_id, cap AS capacidad_max, ocupado AS campers_asignados,
           ROUND((ocupado/cap)*100,2) AS porcentaje_ocupacion,
           (cap - ocupado) AS cupos_disponibles;
END$$

-- 11. Reasignar a un camper a otra ruta en caso de bajo rendimiento.
CREATE PROCEDURE sp_reasignar_camper(
    IN p_id_camper INT,
    IN p_nuevo_id_grupo INT
)
BEGIN
    UPDATE camper
    SET id_grupo = p_nuevo_id_grupo
    WHERE id_camper = p_id_camper;
END$$

-- 12. Cambiar el estado de un camper a 'Graduado' al finalizar todos los módulos.
CREATE PROCEDURE sp_graduar_camper(
    IN p_id_camper INT
)
BEGIN
    UPDATE camper
    SET id_estado = 5  -- Graduado
    WHERE id_camper = p_id_camper;
END$$

-- 13. Consultar y exportar todos los datos de rendimiento de un camper.
CREATE PROCEDURE sp_consultar_rendimiento_camper(
    IN p_id_camper INT
)
BEGIN
    SELECT c.num_identificacion, CONCAT(c.nombres, ' ', c.apellidos) AS nombre,
           m.nombre AS modulo, em.nota_final, em.estado, em.fecha_evaluacion
    FROM evaluacion_modulo em
    JOIN camper c ON em.id_camper = c.id_camper
    JOIN modulo m ON em.id_modulo = m.id_modulo
    WHERE c.id_camper = p_id_camper;
END$$

-- 14. Registrar la asistencia a clases por área y horario.
-- (Se asume la existencia de una tabla "asistencia" con los campos: id_area, id_grupo, fecha, total_asistentes)
CREATE PROCEDURE sp_registrar_asistencia(
    IN p_id_area INT,
    IN p_id_grupo INT,
    IN p_fecha DATE,
    IN p_total_asistentes INT
)
BEGIN
    INSERT INTO asistencia(id_area, id_grupo, fecha, total_asistentes)
    VALUES (p_id_area, p_id_grupo, p_fecha, p_total_asistentes);
END$$

-- 15. Generar reporte mensual de notas por ruta.
CREATE PROCEDURE sp_reporte_mensual_notas(
    IN p_anio INT,
    IN p_mes INT
)
BEGIN
    SELECT r.nombre AS ruta, AVG(em.nota_final) AS promedio_notas, COUNT(em.id_evaluacion) AS total_evaluaciones
    FROM evaluacion_modulo em
    JOIN grupo g ON em.id_grupo = g.id_grupo
    JOIN ruta r ON g.id_ruta = r.id_ruta
    WHERE YEAR(em.fecha_evaluacion) = p_anio AND MONTH(em.fecha_evaluacion) = p_mes
    GROUP BY r.id_ruta, r.nombre;
END$$

-- 16. Validar y registrar la asignación de un salón a una ruta sin exceder la capacidad.
-- (Se asume la existencia de la tabla "salon_asignacion" con campos: id_salon, id_ruta, fecha_asignacion)
CREATE PROCEDURE sp_asignar_salon_a_ruta(
    IN p_id_salon INT,
    IN p_id_ruta INT
)
BEGIN
    DECLARE cap INT;
    DECLARE inscriptos INT;
    SELECT capacidad_max INTO cap FROM area_entrenamiento 
      WHERE id_area = (SELECT id_area FROM grupo WHERE id_ruta = p_id_ruta LIMIT 1);
    SELECT COUNT(*) INTO inscriptos 
      FROM grupo g JOIN camper c ON g.id_grupo = c.id_grupo 
      WHERE g.id_ruta = p_id_ruta AND c.id_estado = 4;
    IF inscriptos < cap THEN
       INSERT INTO salon_asignacion (id_salon, id_ruta, fecha_asignacion)
       VALUES (p_id_salon, p_id_ruta, CURDATE());
    ELSE
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Capacidad excedida para la ruta.';
    END IF;
END$$

-- 17. Registrar cambio de horario de un trainer.
-- (Simulación: se actualiza un campo de la tabla trainer; en un escenario real, se debería actualizar la asignación en trainer_modulo)
CREATE PROCEDURE sp_cambiar_horario_trainer(
    IN p_id_trainer INT,
    IN p_nuevo_id_sede INT
)
BEGIN
    UPDATE trainer
    SET id_sede = p_nuevo_id_sede
    WHERE id_trainer = p_id_trainer;
END$$

-- 18. Eliminar la inscripción de un camper a una ruta (en caso de retiro).
CREATE PROCEDURE sp_eliminar_inscripcion_camper(
    IN p_id_camper INT
)
BEGIN
    UPDATE camper
    SET id_grupo = NULL,
        id_estado = 7  -- Retirado
    WHERE id_camper = p_id_camper;
END$$

-- 19. Recalcular el estado de todos los campers según su rendimiento acumulado.
DELIMITER $$

CREATE PROCEDURE sp_recalcular_estado_campers()
BEGIN
  UPDATE camper
  SET id_estado = CASE
    WHEN IFNULL(
         (SELECT AVG(nota_final) 
          FROM evaluacion_modulo 
          WHERE id_camper = camper.id_camper), 
         0) >= 70 THEN 3  -- Aprobado
    ELSE 4               -- Cursando
  END;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_asignar_horarios_trainers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE var_area INT;
    DECLARE var_horario INT;
    DECLARE var_sede INT;

    -- Cursor para recorrer todas las áreas de entrenamiento
    DECLARE cur_areas CURSOR FOR
         SELECT id_area, id_horario, id_sede FROM area_entrenamiento;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_areas;
    
    read_loop: LOOP
         FETCH cur_areas INTO var_area, var_horario, var_sede;
         IF done THEN
            LEAVE read_loop;
         END IF;
         
         INSERT IGNORE INTO trainer_horario (id_trainer, id_horario, id_area, fecha_asignacion)
         SELECT t.id_trainer, var_horario, var_area, CURDATE()
         FROM trainer t
         WHERE t.id_sede = var_sede
           AND NOT EXISTS (
                SELECT 1 
                FROM trainer_horario th
                WHERE th.id_trainer = t.id_trainer 
                  AND th.id_area = var_area
           );
    END LOOP;
    
    CLOSE cur_areas;
END$$

DELIMITER ;
