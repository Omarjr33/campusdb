DELIMITER $$

/* 1. Al insertar un detalle de evaluación, recalcular la nota final de la evaluación. */
CREATE TRIGGER trg_calcular_nota_final_after_insert_detalle
AFTER INSERT ON detalle_evaluacion
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT ROUND(SUM(de.nota * (ce.porcentaje/100)),2)
      INTO total
      FROM detalle_evaluacion de
      JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
      WHERE de.id_evaluacion = NEW.id_evaluacion;
    UPDATE evaluacion_modulo 
       SET nota_final = total 
     WHERE id_evaluacion = NEW.id_evaluacion;
END$$

/* 2. Al actualizar la nota final de una evaluación, verificar y ajustar su estado (aprobado si nota>=60, reprobado en caso contrario). */
CREATE TRIGGER trg_verificar_estado_before_update_evaluacion
BEFORE UPDATE ON evaluacion_modulo
FOR EACH ROW
BEGIN
    IF NEW.nota_final >= 60 THEN
         SET NEW.estado = 'Aprobado';
    ELSE
         SET NEW.estado = 'Reprobado';
    END IF;
END$$

/* 3. Al insertar una inscripción (es decir, cuando se asigna un grupo a un nuevo camper), cambiar el estado del camper a "Inscrito" (estado 2). */
CREATE TRIGGER trg_inscripcion_camper_before_insert
BEFORE INSERT ON camper
FOR EACH ROW
BEGIN
    IF NEW.id_grupo IS NOT NULL THEN
         SET NEW.id_estado = 2;  -- Inscrito
    END IF;
END$$

/* 4. Al actualizar un detalle de evaluación, recalcular inmediatamente el promedio (nota final) de la evaluación asociada. */
CREATE TRIGGER trg_recalcular_evaluacion_after_update_detalle
AFTER UPDATE ON detalle_evaluacion
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT ROUND(SUM(nota * (ce.porcentaje/100)),2)
      INTO total
      FROM detalle_evaluacion de
      JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
      WHERE de.id_evaluacion = NEW.id_evaluacion;
    UPDATE evaluacion_modulo 
       SET nota_final = total 
     WHERE id_evaluacion = NEW.id_evaluacion;
END$$

/* 5. Al actualizar un camper y quitar su inscripción (es decir, setear id_grupo a NULL), marcarlo como "Retirado" (estado 7). */
CREATE TRIGGER trg_eliminar_inscripcion_camper_before_update
BEFORE UPDATE ON camper
FOR EACH ROW
BEGIN
    IF OLD.id_grupo IS NOT NULL AND NEW.id_grupo IS NULL THEN
         SET NEW.id_estado = 7;  -- Retirado
    END IF;
END$$

/* 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado en base_datos.
   (Ejemplo: clonar "MySQL" como principal y "PostgreSQL" como alternativo; se asume que no se asigna id_ruta en este proceso). */
CREATE TRIGGER trg_nuevo_modulo_after_insert
AFTER INSERT ON modulo
FOR EACH ROW
BEGIN
    INSERT INTO base_datos (nombre, tipo, id_ruta) VALUES ('MySQL', 'Principal', 0);
    INSERT INTO base_datos (nombre, tipo, id_ruta) VALUES ('PostgreSQL', 'Alternativo', 0);
END$$

/* 7. Al insertar un nuevo trainer, verificar duplicados por número de identificación. */
CREATE TRIGGER trg_validar_trainer_duplicado_before_insert
BEFORE INSERT ON trainer
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM trainer WHERE num_identificacion = NEW.num_identificacion) > 0 THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Ya existe un trainer con esa identificación';
    END IF;
END$$

/* 8. Al insertar (o actualizar) un camper con inscripción (id_grupo no nulo), validar que el área asociada no exceda su capacidad. */
CREATE TRIGGER trg_validar_cupo_area_before_insert_camper
BEFORE INSERT ON camper
FOR EACH ROW
BEGIN
    IF NEW.id_grupo IS NOT NULL THEN
         DECLARE area INT;
         DECLARE cap INT;
         DECLARE ocu INT;
         SELECT id_area INTO area FROM grupo WHERE id_grupo = NEW.id_grupo;
         SELECT capacidad_max INTO cap FROM area_entrenamiento WHERE id_area = area;
         SELECT COUNT(*) INTO ocu
           FROM grupo g
           JOIN camper c ON g.id_grupo = c.id_grupo
           WHERE g.id_area = area AND c.id_estado = 4;  -- suponiendo que los "Cursando" se cuentan
         IF ocu >= cap THEN
              SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = 'No hay cupos disponibles en el área asignada';
         END IF;
    END IF;
END$$

/* 9. Al insertar una evaluación (en evaluacion_modulo) con nota final menor a 60, marcar al camper como "Bajo rendimiento".
   (Aquí, para ilustrar, actualizamos el campo 'acudiente' agregando la etiqueta "Bajo rendimiento"). */
CREATE TRIGGER trg_marcar_bajo_rendimiento_after_insert_evaluacion
AFTER INSERT ON evaluacion_modulo
FOR EACH ROW
BEGIN
    IF NEW.nota_final < 60 THEN
         UPDATE camper
         SET acudiente = CONCAT(IFNULL(acudiente, ''), ' - Bajo rendimiento')
         WHERE id_camper = NEW.id_camper;
    END IF;
END$$

/* 10. Al cambiar el estado de un camper a “Graduado” (estado 5), mover automáticamente su registro a la tabla de egresados.
   Se asume que existe la tabla "egresados" con al menos: id_camper, num_identificacion, nombres, apellidos, fecha_graduacion.
*/
CREATE TRIGGER trg_mover_a_egresados_after_update_camper
AFTER UPDATE ON camper
FOR EACH ROW
BEGIN
    IF OLD.id_estado <> 5 AND NEW.id_estado = 5 THEN
         INSERT INTO egresados (id_camper, num_identificacion, nombres, apellidos, fecha_graduacion)
         VALUES (NEW.id_camper, NEW.num_identificacion, NEW.nombres, NEW.apellidos, CURDATE());
    END IF;
END$$

/* 11. Al modificar horarios de un trainer, verificar solapamiento con otros.
   (Ejemplo simplificado: se activa en la tabla trainer_horario)
   Asumimos que un trainer no puede tener dos asignaciones con el mismo id_horario en el mismo área.
*/
CREATE TRIGGER trg_solapamiento_trainer_before_insert
BEFORE INSERT ON trainer_horario
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM trainer_horario 
        WHERE id_trainer = NEW.id_trainer AND id_area = NEW.id_area AND id_horario = NEW.id_horario) > 0 THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'El trainer ya tiene asignado ese horario en el área';
    END IF;
END$$

/* 12. Al eliminar un trainer, liberar sus asignaciones:
   Se eliminan registros relacionados en trainer_horario, trainer_grupo y trainer_modulo.
*/
CREATE TRIGGER trg_liberar_asignacion_trainer_after_delete
AFTER DELETE ON trainer
FOR EACH ROW
BEGIN
    DELETE FROM trainer_horario WHERE id_trainer = OLD.id_trainer;
    DELETE FROM trainer_grupo WHERE id_trainer = OLD.id_trainer;
    DELETE FROM trainer_modulo WHERE id_trainer = OLD.id_trainer;
END$$

/* 13. Al cambiar la ruta de un camper (cambio en id_grupo), actualizar automáticamente sus evaluaciones.
   Se eliminan las evaluaciones viejas y se crean nuevas basadas en la ruta del nuevo grupo.
*/
CREATE TRIGGER trg_actualizar_evaluaciones_camper_after_update
AFTER UPDATE ON camper
FOR EACH ROW
BEGIN
    IF OLD.id_grupo <> NEW.id_grupo AND NEW.id_grupo IS NOT NULL THEN
         DELETE FROM evaluacion_modulo WHERE id_camper = NEW.id_camper;
         INSERT INTO evaluacion_modulo (id_camper, id_modulo, id_grupo, nota_final, estado, fecha_evaluacion)
         SELECT NEW.id_camper, rm.id_modulo, NEW.id_grupo, 0, 'Pendiente', CURDATE()
         FROM ruta_modulo rm
         JOIN grupo g ON rm.id_ruta = g.id_ruta
         WHERE g.id_grupo = NEW.id_grupo;
    END IF;
END$$

/* 14. Al insertar un nuevo camper, verificar que su número de identificación no esté duplicado. */
CREATE TRIGGER trg_validar_camper_duplicado_before_insert
BEFORE INSERT ON camper
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM camper WHERE num_identificacion = NEW.num_identificacion) > 0 THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Ya existe un camper con ese número de identificación.';
    END IF;
END$$

/* 15. Al actualizar la nota final de un módulo (en evaluacion_modulo), recalcular el estado del módulo automáticamente.
   (Este trigger se solapa conceptualmente con el 2, por lo que se puede combinar o sustituir.)
*/
CREATE TRIGGER trg_recalcular_estado_before_update_evaluacion
BEFORE UPDATE ON evaluacion_modulo
FOR EACH ROW
BEGIN
    IF NEW.nota_final >= 60 THEN
         SET NEW.estado = 'Aprobado';
    ELSE
         SET NEW.estado = 'Reprobado';
    END IF;
END$$

/* 16. Al asignar un módulo a un trainer (en trainer_modulo), verificar que el trainer tenga ese conocimiento.
   Se asume la existencia de la tabla trainer_conocimiento (id_trainer, id_modulo).
*/
CREATE TRIGGER trg_verificar_conocimiento_trainer_before_insert
BEFORE INSERT ON trainer_modulo
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM trainer_conocimiento WHERE id_trainer = NEW.id_trainer AND id_modulo = NEW.id_modulo) = 0 THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'El trainer no tiene conocimiento del módulo asignado';
    END IF;
END$$

/* 17. Al cambiar el estado de un área a inactiva, liberar los campers asignados a ella.
   Se asume que el área tiene un campo 'activo' (1 = activo, 0 = inactivo).
*/
CREATE TRIGGER trg_liberar_camper_area_after_update
AFTER UPDATE ON area_entrenamiento
FOR EACH ROW
BEGIN
    IF OLD.activo = 1 AND NEW.activo = 0 THEN
         UPDATE camper c
         JOIN grupo g ON c.id_grupo = g.id_grupo
         SET c.id_grupo = NULL, c.id_estado = 7
         WHERE g.id_area = NEW.id_area;
    END IF;
END$$

/* 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDB.
   Se asume que la "plantilla base" son los módulos 1 y 2 y SGDB: MySQL y PostgreSQL.
*/
CREATE TRIGGER trg_clonar_plantilla_after_insert_ruta
AFTER INSERT ON ruta
FOR EACH ROW
BEGIN
    INSERT INTO ruta_modulo (id_ruta, id_modulo, orden)
      VALUES (NEW.id_ruta, 1, 1), (NEW.id_ruta, 2, 2);
    INSERT INTO base_datos (nombre, tipo, id_ruta)
      VALUES ('MySQL', 'Principal', NEW.id_ruta), ('PostgreSQL', 'Alternativo', NEW.id_ruta);
END$$

/* 19. Al registrar la nota práctica (detalle_evaluacion para criterio que contenga 'Práctica'),
   verificar que no supere el 60% del porcentaje asignado a ese criterio.
*/
CREATE TRIGGER trg_validar_nota_practica_before_insert
BEFORE INSERT ON detalle_evaluacion
FOR EACH ROW
BEGIN
    DECLARE perc DECIMAL(5,2);
    DECLARE criterio_nombre VARCHAR(100);
    SELECT nombre, porcentaje INTO criterio_nombre, perc FROM criterio_evaluacion WHERE id_criterio = NEW.id_criterio;
    IF criterio_nombre LIKE '%Práctica%' THEN
         IF NEW.nota > (perc * 0.6) THEN
              SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = 'La nota práctica no puede superar el 60% del total asignado al criterio';
         END IF;
    END IF;
END$$

/* 20. Al modificar una ruta, notificar cambios a los trainers asignados.
   Se asume la existencia de una tabla notifications(id, message, fecha).
*/
CREATE TRIGGER trg_notificar_cambio_ruta_after_update
AFTER UPDATE ON ruta
FOR EACH ROW
BEGIN
    INSERT INTO notifications (message, fecha)
    SELECT CONCAT('La ruta "', NEW.nombre, '" ha sido modificada.') AS message, CURDATE();
    -- Nota: Este trigger inserta una notificación general. En un entorno real, se deberían notificar 
    -- individualmente a cada trainer asignado a la ruta.
END$$

DELIMITER ;
