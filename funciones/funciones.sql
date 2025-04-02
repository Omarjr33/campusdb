DELIMITER $$

/* 1. Calcular el promedio ponderado de evaluaciones de un camper */
CREATE FUNCTION fn_promedio_ponderado_camper(p_id_camper INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE avg_weight DECIMAL(5,2);
    SELECT AVG(eval_weight)
      INTO avg_weight
      FROM (
           SELECT ROUND(SUM(de.nota * ce.porcentaje / 100), 2) AS eval_weight
           FROM evaluacion_modulo e
           JOIN detalle_evaluacion de ON e.id_evaluacion = de.id_evaluacion
           JOIN criterio_evaluacion ce ON de.id_criterio = ce.id_criterio
           WHERE e.id_camper = p_id_camper
           GROUP BY e.id_evaluacion
         ) AS t;
    RETURN IFNULL(avg_weight, 0);
END$$

/* 2. Determinar si un camper aprueba o no un módulo específico */
CREATE FUNCTION fn_aprueba_modulo(p_id_camper INT, p_id_modulo INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE nota DECIMAL(5,2);
    SELECT AVG(nota_final)
      INTO nota
      FROM evaluacion_modulo
      WHERE id_camper = p_id_camper AND id_modulo = p_id_modulo;
    IF IFNULL(nota, 0) >= 60 THEN
         RETURN 1;
    ELSE
         RETURN 0;
    END IF;
END$$

/* 3. Evaluar el nivel de riesgo de un camper según su rendimiento promedio */
CREATE FUNCTION fn_nivel_riesgo_camper(p_id_camper INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SET promedio = fn_promedio_ponderado_camper(p_id_camper);
    IF promedio < 60 THEN
         RETURN 'Alto';
    ELSEIF promedio < 70 THEN
         RETURN 'Medio';
    ELSE
         RETURN 'Bajo';
    END IF;
END$$

/* 4. Obtener el total de campers asignados a una ruta específica */
CREATE FUNCTION fn_total_campers_ruta(p_id_ruta INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(DISTINCT c.id_camper)
      INTO total
      FROM grupo g
      JOIN camper c ON g.id_grupo = c.id_grupo
      WHERE g.id_ruta = p_id_ruta;
    RETURN IFNULL(total, 0);
END$$

/* 5. Consultar la cantidad de módulos que ha aprobado un camper */
CREATE FUNCTION fn_modulos_aprobados_camper(p_id_camper INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count_mod INT;
    SELECT COUNT(*) INTO count_mod
    FROM (
         SELECT id_modulo, AVG(nota_final) AS prom
         FROM evaluacion_modulo
         WHERE id_camper = p_id_camper
         GROUP BY id_modulo
         HAVING prom >= 60
         ) AS t;
    RETURN IFNULL(count_mod, 0);
END$$

/* 6. Validar si hay cupos disponibles en una determinada área */
CREATE FUNCTION fn_cupos_disponibles_area(p_id_area INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cap INT;
    DECLARE ocupados INT;
    SELECT capacidad_max INTO cap FROM area_entrenamiento WHERE id_area = p_id_area;
    SELECT COUNT(*) INTO ocupados
      FROM grupo g
      JOIN camper c ON g.id_grupo = c.id_grupo
      WHERE g.id_area = p_id_area AND c.id_estado = 4;
    RETURN cap - IFNULL(ocupados, 0);
END$$

/* 7. Calcular el porcentaje de ocupación de un área de entrenamiento */
CREATE FUNCTION fn_porcentaje_ocupacion_area(p_id_area INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE cap INT;
    DECLARE ocupados INT;
    DECLARE porcentaje DECIMAL(5,2);
    SELECT capacidad_max INTO cap FROM area_entrenamiento WHERE id_area = p_id_area;
    SELECT COUNT(*) INTO ocupados
      FROM grupo g
      JOIN camper c ON g.id_grupo = c.id_grupo
      WHERE g.id_area = p_id_area AND c.id_estado = 4;
    SET porcentaje = (ocupados/cap)*100;
    RETURN IFNULL(ROUND(porcentaje,2), 0);
END$$

/* 8. Determinar la nota más alta obtenida en un módulo */
CREATE FUNCTION fn_nota_max_modulo(p_id_modulo INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE max_nota DECIMAL(5,2);
    SELECT MAX(nota_final) INTO max_nota
      FROM evaluacion_modulo
      WHERE id_modulo = p_id_modulo;
    RETURN IFNULL(max_nota, 0);
END$$

/* 9. Calcular la tasa de aprobación de una ruta */
CREATE FUNCTION fn_tasa_aprobacion_ruta(p_id_ruta INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_eval INT;
    DECLARE aprob_eval INT;
    DECLARE tasa DECIMAL(5,2);
    SELECT COUNT(e.id_evaluacion) INTO total_eval
      FROM evaluacion_modulo e
      JOIN grupo g ON e.id_grupo = g.id_grupo
      WHERE g.id_ruta = p_id_ruta;
    SELECT COUNT(e.id_evaluacion) INTO aprob_eval
      FROM evaluacion_modulo e
      JOIN grupo g ON e.id_grupo = g.id_grupo
      WHERE g.id_ruta = p_id_ruta AND e.estado = 'Aprobado';
    SET tasa = (IFNULL(aprob_eval, 0)/IFNULL(total_eval,1))*100;
    RETURN ROUND(tasa, 2);
END$$

/* 10. Verificar si un trainer tiene horario disponible para un horario dado */
CREATE FUNCTION fn_trainer_tiene_horario_disponible(p_id_trainer INT, p_id_horario INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count_conflict INT;
    SELECT COUNT(*) INTO count_conflict
      FROM trainer_horario
      WHERE id_trainer = p_id_trainer AND id_horario = p_id_horario;
    IF count_conflict = 0 THEN
         RETURN 1;
    ELSE
         RETURN 0;
    END IF;
END$$

/* 11. Obtener el promedio de notas por ruta */
CREATE FUNCTION fn_promedio_notas_ruta(p_id_ruta INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE prom DECIMAL(5,2);
    SELECT ROUND(AVG(e.nota_final), 2)
      INTO prom
      FROM evaluacion_modulo e
      JOIN grupo g ON e.id_grupo = g.id_grupo
      WHERE g.id_ruta = p_id_ruta;
    RETURN IFNULL(prom, 0);
END$$

/* 12. Calcular cuántas rutas tiene asignadas un trainer */
CREATE FUNCTION fn_rutas_asignadas_trainer(p_id_trainer INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE rutas INT;
    SELECT COUNT(DISTINCT g.id_ruta)
      INTO rutas
      FROM trainer_grupo tg
      JOIN grupo g ON tg.id_grupo = g.id_grupo
      WHERE tg.id_trainer = p_id_trainer;
    RETURN IFNULL(rutas, 0);
END$$

/* 13. Verificar si un camper puede ser graduado (aprobó todos los módulos de su ruta) */
CREATE FUNCTION fn_puede_graduarse(p_id_camper INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE modulos_aprobados INT;
    DECLARE total_modulos INT;
    DECLARE id_ruta INT;
    
    SELECT g.id_ruta INTO id_ruta
      FROM grupo g
      JOIN camper c ON g.id_grupo = c.id_grupo
      WHERE c.id_camper = p_id_camper
      LIMIT 1;
    
    SET modulos_aprobados = fn_modulos_aprobados_camper(p_id_camper);
    
    SELECT COUNT(*) INTO total_modulos FROM ruta_modulo WHERE id_ruta = id_ruta;
    
    IF total_modulos > 0 AND modulos_aprobados = total_modulos THEN
         RETURN 1;
    ELSE
         RETURN 0;
    END IF;
END$$

/* 14. Obtener el estado actual de un camper en función de sus evaluaciones */
CREATE FUNCTION fn_estado_camper(p_id_camper INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SET promedio = fn_promedio_ponderado_camper(p_id_camper);
    IF promedio >= 70 THEN
         RETURN 'Aprobado';
    ELSE
         RETURN 'Cursando';
    END IF;
END$$

/* 15. Calcular la carga horaria semanal de un trainer (simulación: 20 horas por asignación) */
CREATE FUNCTION fn_carga_horaria_trainer(p_id_trainer INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE carga DECIMAL(5,2);
    SELECT COUNT(*)
      INTO carga
      FROM trainer_modulo
      WHERE id_trainer = p_id_trainer;
    -- Suponiendo que cada asignación equivale a 20 horas semanales:
    RETURN carga * 20;
END$$

/* 16. Determinar si una ruta tiene módulos pendientes por evaluación.
   (Retorna 1 si hay módulos de la ruta sin evaluación para al menos un camper, 0 en caso contrario) */
CREATE FUNCTION fn_ruta_pendiente_evaluacion(p_id_ruta INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_mod INT;
    DECLARE eval_mod INT;
    SELECT COUNT(*) INTO total_mod FROM ruta_modulo WHERE id_ruta = p_id_ruta;
    SELECT COUNT(DISTINCT id_modulo) INTO eval_mod
      FROM evaluacion_modulo
      WHERE id_camper IN (
            SELECT c.id_camper
            FROM grupo g
            JOIN camper c ON g.id_grupo = c.id_grupo
            WHERE g.id_ruta = p_id_ruta
      );
    IF eval_mod < total_mod THEN 
         RETURN 1;
    ELSE 
         RETURN 0;
    END IF;
END$$

/* 17. Calcular el promedio general del programa */
CREATE FUNCTION fn_promedio_general_programa()
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE prom DECIMAL(5,2);
    SELECT ROUND(AVG(nota_final), 2)
      INTO prom
      FROM evaluacion_modulo;
    RETURN IFNULL(prom, 0);
END$$

/* 18. Verificar si un horario choca con otros entrenadores en un área.
   (Retorna 1 si hay solapamiento, 0 si no hay) */
CREATE FUNCTION fn_horario_choca(p_id_area INT, p_id_horario INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count_conf INT;
    SELECT COUNT(*) INTO count_conf
      FROM trainer_horario
      WHERE id_area = p_id_area AND id_horario = p_id_horario;
    IF count_conf > 0 THEN 
         RETURN 1;
    ELSE 
         RETURN 0;
    END IF;
END$$

/* 19. Calcular cuántos campers están en riesgo (promedio < 60) en una ruta específica */
CREATE FUNCTION fn_campers_en_riesgo_ruta(p_id_ruta INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt
      FROM (
         SELECT c.id_camper, fn_promedio_ponderado_camper(c.id_camper) AS prom
         FROM grupo g
         JOIN camper c ON g.id_grupo = c.id_grupo
         WHERE g.id_ruta = p_id_ruta
      ) AS t
      WHERE t.prom < 60;
    RETURN IFNULL(cnt, 0);
END$$

/* 20. Consultar el número de módulos evaluados por un camper */
CREATE FUNCTION fn_modulos_evaluados_camper(p_id_camper INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(DISTINCT id_modulo)
      INTO cnt
      FROM evaluacion_modulo
      WHERE id_camper = p_id_camper;
    RETURN IFNULL(cnt, 0);
END$$

DELIMITER ;
