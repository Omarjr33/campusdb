-- 1. Ciudades 
INSERT INTO ciudad (id_ciudad, nombre, departamento) VALUES
  (1, 'Bogotá', 'Distrito Capital'),
  (2, 'Medellín', 'Antioquia'),
  (3, 'Cali', 'Valle del Cauca');

-- 2. Horarios
INSERT INTO horario (id_horario, jornada, hora_inicio, hora_fin) VALUES
  (1, 'Mañana', '08:00:00', '12:00:00'),
  (2, 'Tarde', '13:00:00', '17:00:00');

-- 3. Sedes
INSERT INTO sede (id_sede, nombre, direccion, telefono, email, id_ciudad) VALUES
  (1, 'Sede Bogotá', 'Cra 7 # 25-10, Bogotá', '031-1234567', 'bogota@example.com', 1),
  (2, 'Sede Medellín', 'Calle 10 # 35-20, Medellín', '04-7654321', 'medellin@example.com', 2),
  (3, 'Sede Cali', 'Av. 3N # 10-30, Cali', '02-9876543', 'cali@example.com', 3);

-- 4. Estado de Camper
INSERT INTO estado_camper (id_estado, nombre_estado, nivel_riesgo) VALUES
  (1, 'Preinscrito', 'Bajo'),
  (2, 'Inscrito', 'Bajo'),
  (3, 'Aprobado', 'Medio'),
  (4, 'Cursando', 'Alto'),
  (5, 'Graduado', 'Bajo'),
  (6, 'Expulsado', 'Alto'),
  (7, 'Retirado', 'Medio');

-- 5. Rutas
INSERT INTO ruta (id_ruta, nombre, descripcion, duracion_meses) VALUES
  (1, 'Data Science', 'Curso de ciencia de datos', 6),
  (2, 'Web Development', 'Curso de desarrollo web', 4),
  (3, 'Network Security', 'Curso de seguridad en redes', 5);

-- 6. Áreas de Entrenamiento  
INSERT INTO area_entrenamiento (id_area, nombre, capacidad_max, ubicacion, id_sede, id_horario) VALUES
  (1, 'Laboratorio de Computación', 30, 'Edificio Central, Bogotá', 1, 1),
  (2, 'Aula Virtual', 20, 'Edificio Tech, Medellín', 2, 2),
  (3, 'Sala de Conferencias', 15, 'Edificio Seg, Cali', 3, 1);

-- 7. Grupos
INSERT INTO grupo (id_grupo, nombre, fecha_inicio, fecha_fin, id_ruta, id_area) VALUES
  (1, 'j1', '2025-01-10', '2025-06-10', 1, 1),
  (2, 'j2', '2025-01-10', '2025-06-10', 1, 1),
  (3, 'm1', '2025-02-01', '2025-07-01', 2, 2),
  (4, 'm2', '2025-02-01', '2025-07-01', 2, 2),
  (5, 'h1', '2025-03-01', '2025-08-01', 3, 3),
  (6, 'h2', '2025-03-01', '2025-08-01', 3, 3);

-- 8. Campers
INSERT INTO camper (id_camper, num_identificacion, nombres, apellidos, direccion, accidente, telefono, email, acudiente, fecha_nacimiento, id_estado, id_grupo, id_sede, fecha_registro) VALUES
  (10, '100100100', 'Juan', 'Perez', 'Cra 1 # 10-10, Bogotá', NULL, '310-1111111', 'juan.perez@correo.co', 'Pedro Perez', '2000-05-10', 2, 1, 1, '2025-01-02'),
  (11, '100200200', 'Maria', 'Gomez', 'Calle 15 # 45-20, Bogotá', NULL, '310-2222222', 'maria.gomez@correo.co', 'Ana Gomez', '1999-08-15', 3, 1, 1, '2025-01-03'),
  (12, '100300300', 'Luis', 'Lopez', 'Carrera 10 # 20-30, Medellín', NULL, '312-3333333', 'luis.lopez@correo.co', NULL, '2001-11-20', 3, 3, 2, '2025-02-05'),
  (13, '100400400', 'Ana', 'Martinez', 'Avenida 5 # 30-50, Bogotá', NULL, '310-4444444', 'ana.martinez@correo.co', 'Pedro Martinez', '1998-12-12', 5, 1, 1, '2025-02-07'),
  (14, '100500500', 'Ricardo', 'Ramirez', 'Calle 20 # 15-25, Cali', NULL, '312-5555555', 'ricardo.ramirez@correo.co', 'Laura Ramirez', '1997-03-03', 6, 5, 3, '2025-03-10'),
  (15, '100600600', 'Sofia', 'Torres', 'Carrera 3 # 12-34, Cali', NULL, '312-6666666', 'sofia.torres@correo.co', 'Carlos Torres', '2002-02-02', 7, 5, 3, '2025-03-11'),
  (16, '100700700', 'Diego', 'Hernandez', 'Calle 8 # 20-15, Medellín', NULL, '312-7777777', 'diego.hernandez@correo.co', 'Maria Hernandez', '2000-07-07', 4, 2, 1, '2025-01-20'),
  (17, '100800800', 'Elena', 'Flores', 'Carrera 7 # 18-20, Medellín', NULL, '312-8888888', 'elena.flores@correo.co', NULL, '2001-10-10', 3, 2, 1, '2025-01-22'),
  (18, '100900900', 'Marco', 'Sanchez', 'Cra 12 # 50-60, Bogotá', NULL, '310-9999999', 'marco.sanchez@correo.co', 'Lucia Sanchez', '1995-06-06', 4, 2, 1, '2025-01-05'),
  (19, '101000100', 'Claudia', 'Diaz', 'Calle 3 # 11-22, Medellín', NULL, '312-1010101', 'claudia.diaz@correo.co', 'Jose Diaz', '1994-04-04', 5, 3, 2, '2025-02-10'),
  (20, '101100110', 'Andres', 'Santos', 'Av. 19 # 30-40, Bogotá', NULL, '310-1110101', 'andres.santos@correo.co', 'Luis Santos', '2000-01-01', 2, NULL, 1, '2025-04-01');

-- 9. INSERTAR CAMPERS ADICIONALES.
INSERT INTO camper (id_camper, num_identificacion, nombres, apellidos, direccion, accidente, telefono, email, acudiente, fecha_nacimiento, id_estado, id_grupo, id_sede, fecha_registro) VALUES
  (100, '110000100', 'Camilo', 'Gutierrez', 'Cra 1 # 10-10, Bogotá', NULL, '310-111100', 'camilo.gutierrez@correo.co', 'Marta Gutierrez', '2000-01-10', 4, 1, 1, '2025-01-10'),
  (101, '110000101', 'Sofia', 'Martinez', 'Calle 3 # 15-20, Bogotá', NULL, '310-111101', 'sofia.martinez@correo.co', 'Juan Martinez', '2000-02-10', 4, 1, 1, '2025-01-10'),
  (102, '110000102', 'Esteban', 'Rojas', 'Av. 10 # 20-30, Bogotá', NULL, '310-111102', 'esteban.rojas@correo.co', 'Rosa Rojas', '2000-03-10', 4, 1, 1, '2025-01-10'),
  (103, '110000103', 'Valentina', 'Gómez', 'Calle 7 # 10-11, Bogotá', NULL, '310-111103', 'valentina.gomez@correo.co', 'Carlos Gómez', '2000-04-10', 4, 1, 1, '2025-01-10'),
  (104, '110000104', 'Gabriel', 'Lopez', 'Cra 5 # 15-16, Bogotá', NULL, '310-111104', 'gabriel.lopez@correo.co', 'Ana Lopez', '2000-05-10', 4, 1, 1, '2025-01-10'),
  (105, '110000105', 'Isabella', 'Martinez', 'Calle 9 # 20-21, Bogotá', NULL, '310-111105', 'isabella.martinez@correo.co', 'Jorge Martinez', '2000-06-10', 4, 1, 1, '2025-01-10'),
  (106, '110000106', 'Sebastián', 'Gutiérrez', 'Av. 4 # 5-6, Bogotá', NULL, '310-111106', 'sebastian.gutierrez@correo.co', 'Diana Gutierrez', '2000-07-10', 4, 1, 1, '2025-01-10'),
  (107, '110000107', 'Manuela', 'Orozco', 'Cra 3 # 8-9, Bogotá', NULL, '310-111107', 'manuela.orozco@correo.co', 'Julio Orozco', '2000-08-10', 4, 1, 1, '2025-01-10'),
  (108, '110000108', 'Martín', 'Castro', 'Calle 2 # 12-13, Bogotá', NULL, '310-111108', 'martin.castro@correo.co', 'Laura Castro', '2000-09-10', 4, 1, 1, '2025-01-10'),
  (109, '110000109', 'Paula', 'Molina', 'Av. 6 # 14-15, Bogotá', NULL, '310-111109', 'paula.molina@correo.co', 'Andrés Molina', '2000-10-10', 4, 1, 1, '2025-01-10'),
  (110, '110000110', 'Juan David', 'Soto', 'Cra 1 # 5-5, Bogotá', NULL, '310-111110', 'juandavid.soto@correo.co', 'Camila Soto', '2000-11-10', 4, 1, 1, '2025-01-10'),
  (111, '110000111', 'Mariana', 'Suárez', 'Calle 3 # 6-7, Bogotá', NULL, '310-111111', 'mariana.suarez@correo.co', 'Miguel Suárez', '2000-12-10', 4, 1, 1, '2025-01-10'),
  (112, '110000112', 'Diego', 'Correa', 'Av. 2 # 10-11, Bogotá', NULL, '310-111112', 'diego.correa@correo.co', 'Silvia Correa', '2000-01-15', 4, 1, 1, '2025-01-10'),
  (113, '110000113', 'Laura', 'Barrera', 'Cra 3 # 14-15, Bogotá', NULL, '310-111113', 'laura.barrera@correo.co', 'Ricardo Barrera', '2000-02-15', 4, 1, 1, '2025-01-10'),
  (114, '110000114', 'Andrés', 'Moreno', 'Calle 7 # 8-9, Bogotá', NULL, '310-111114', 'andres.moreno@correo.co', 'Patricia Moreno', '2000-03-15', 4, 1, 1, '2025-01-10'),
  (115, '110000115', 'Catalina', 'Díaz', 'Av. 8 # 10-11, Bogotá', NULL, '310-111115', 'catalina.diaz@correo.co', 'Oscar Díaz', '2000-04-15', 4, 1, 1, '2025-01-10'),
  (116, '110000116', 'Felipe', 'Vargas', 'Cra 4 # 16-17, Bogotá', NULL, '310-111116', 'felipe.vargas@correo.co', 'Daniel Vargas', '2000-05-15', 4, 1, 1, '2025-01-10'),
  (117, '110000117', 'Daniela', 'Cárdenas', 'Calle 1 # 20-21, Bogotá', NULL, '310-111117', 'daniela.cardenas@correo.co', 'Alejandra Cárdenas', '2000-06-15', 4, 1, 1, '2025-01-10'),
  (118, '110000118', 'Miguel', 'Patiño', 'Av. 3 # 8-9, Bogotá', NULL, '310-111118', 'miguel.patino@correo.co', 'Verónica Patiño', '2000-07-15', 4, 1, 1, '2025-01-10'),
  (119, '110000119', 'Brayan', 'Ordóñez', 'Cra 2 # 11-12, Bogotá', NULL, '310-111119', 'brayan.ordonez@correo.co', 'Cristina Ordóñez', '2000-08-15', 4, 1, 1, '2025-01-10'),
  (120, '110000120', 'Tatiana', 'Restrepo', 'Calle 5 # 14-15, Bogotá', NULL, '310-111120', 'tatiana.restrepo@correo.co', 'Nicolás Restrepo', '2000-09-15', 4, 1, 1, '2025-01-10'),
  (121, '110000121', 'Ricardo', 'Jiménez', 'Av. 4 # 15-16, Bogotá', NULL, '310-111121', 'ricardo.jimenez@correo.co', 'Patricia Jiménez', '2000-10-15', 4, 1, 1, '2025-01-10'),
  (122, '110000122', 'Paola', 'García', 'Cra 6 # 10-11, Bogotá', NULL, '310-111122', 'paola.garcia@correo.co', 'Carlos García', '2000-11-15', 4, 1, 1, '2025-01-10'),
  (123, '110000123', 'Jorge', 'Molina', 'Calle 4 # 16-17, Bogotá', NULL, '310-111123', 'jorge.molina@correo.co', 'Isabel Molina', '2000-12-15', 4, 1, 1, '2025-01-10'),
  (124, '110000124', 'Verónica', 'Salazar', 'Av. 1 # 12-13, Bogotá', NULL, '310-111124', 'veronica.salazar@correo.co', 'Julio Salazar', '2000-01-20', 4, 1, 1, '2025-01-10'),
  (125, '110000125', 'Oscar', 'Castro', 'Cra 7 # 17-18, Bogotá', NULL, '310-111125', 'oscar.castro@correo.co', 'Miguel Castro', '2000-02-20', 4, 1, 1, '2025-01-10'),
  (126, '110000126', 'Daniel', 'Castaño', 'Calle 2 # 20-21, Bogotá', NULL, '310-111126', 'daniel.castano@correo.co', 'Laura Castaño', '2000-03-20', 4, 1, 1, '2025-01-10'),
  (127, '110000127', 'Martha', 'Sánchez', 'Av. 3 # 22-23, Bogotá', NULL, '310-111127', 'martha.sanchez@correo.co', 'Eduardo Sánchez', '2000-04-20', 4, 1, 1, '2025-01-10'),
  (128, '110000128', 'Armando', 'Ruiz', 'Cra 5 # 24-25, Bogotá', NULL, '310-111128', 'armando.ruiz@correo.co', 'Diana Ruiz', '2000-05-20', 4, 1, 1, '2025-01-10'),
  (129, '110000129', 'Andrea', 'Torres', 'Calle 8 # 26-27, Bogotá', NULL, '310-111129', 'andrea.torres@correo.co', 'Julio Torres', '2000-06-20', 4, 1, 1, '2025-01-10');

-- 10. Módulos
INSERT INTO modulo (id_modulo, nombre, descripcion, duracion_semanas, tipo) VALUES
  (1, 'Python Basics', 'Introducción a Python', 4, 'Técnico'),
  (2, 'Machine Learning', 'Conceptos de ML', 6, 'Técnico'),
  (3, 'Teamwork', 'Habilidades blandas', 2, 'Soft Skill'),
  (4, 'HTML & CSS', 'Fundamentos de la Web', 3, 'Técnico'),
  (5, 'JavaScript', 'Programación en JS', 5, 'Técnico'),
  (6, 'Communication', 'Habilidades de comunicación', 2, 'Soft Skill'),
  (7, 'Security Fundamentals', 'Conceptos de seguridad', 4, 'Técnico'),
  (8, 'Ethical Hacking', 'Hacking ético', 5, 'Técnico'),
  (9, 'English Basics', 'Inglés para profesionales', 4, 'Inglés'),
  (10, 'Leadership', 'Desarrollo de liderazgo', 3, 'Ser');


-- 12. Tecnologías
INSERT INTO tecnologia (id_tecnologia, nombre, descripcion, id_modulo) VALUES
  (1, 'TensorFlow', 'Framework de ML', 2),
  (2, 'React', 'Librería de interfaz web', 5),
  (3, 'Wireshark', 'Analizador de red', 7);

-- 13. Ruta_Modulo
INSERT INTO ruta_modulo (id_ruta_modulo, id_ruta, id_modulo, orden) VALUES
  (1, 1, 1, 1),
  (2, 1, 2, 2),
  (3, 1, 3, 3),
  (4, 1, 10, 4),
  (5, 2, 4, 1),
  (6, 2, 5, 2),
  (7, 2, 6, 3),
  (8, 3, 7, 1),
  (9, 3, 8, 2),
  (10, 3, 9, 3);

-- 14. Base_Datos
INSERT INTO base_datos (id_bd, nombre, tipo, id_ruta) VALUES
  (1, 'MySQL', 'Principal', 1),
  (2, 'PostgreSQL', 'Alternativo', 1),
  (3, 'Oracle', 'Principal', 2),
  (4, 'SQLite', 'Alternativo', 2),
  (5, 'MySQL', 'Principal', 3),
  (6, 'MariaDB', 'Alternativo', 3);

-- 15. Trainers
INSERT INTO trainer (id_trainer, num_identificacion, nombres, apellidos, especialidad, email, telefono, id_sede) VALUES
  (1, '900100100', 'Carlos', 'Ramirez', 'Data Science', 'carlos.ramirez@correo.co', '310-1234567', 1),
  (2, '900200200', 'Laura', 'Martinez', 'Web Development', 'laura.martinez@correo.co', '311-9876543', 2),
  (3, '900300300', 'Pedro', 'Gomez', 'Network Security', 'pedro.gomez@correo.co', '312-1234987', 3),
  (4, '900400400', 'Sergio', 'Lopez', 'Full Stack', 'sergio.lopez@correo.co', '313-6543210', 1);

-- 16. Trainer_Grupo
INSERT INTO trainer_grupo (id_trainer_grupo, id_trainer, id_grupo, fecha_asignacion) VALUES
  (1, 1, 1, '2025-01-05'),
  (2, 1, 2, '2025-01-07'),
  (3, 2, 3, '2025-02-05'),
  (4, 3, 5, '2025-03-10'),
  (5, 4, 4, '2025-01-06');

-- 17. Trainer_Modulo
INSERT INTO trainer_modulo (id_trainer_modulo, id_trainer, id_modulo, id_grupo, fecha_inicio, fecha_fin) VALUES
  (1, 1, 1, 1, '2025-01-05', '2025-02-05'),
  (2, 1, 2, 1, '2025-01-06', '2025-03-06'),
  (3, 2, 4, 3, '2025-02-06', '2025-03-06'),
  (4, 2, 5, 3, '2025-02-07', '2025-04-07'),
  (5, 3, 7, 5, '2025-03-16', '2025-04-16'),
  (6, 4, 1, 2, '2025-01-08', '2025-02-08');

-- 18. Evaluacion_Trainer
INSERT INTO evaluacion_trainer (id_eval_trainer, id_trainer, id_modulo, id_camper, calificacion, comentarios, fecha_asignacion) VALUES
  (1, 1, 1, 10, 85.0, 'Muy bien', '2025-02-10');

-- 19. Evaluacion_Modulo
INSERT INTO evaluacion_modulo (id_evaluacion, id_camper, id_modulo, id_grupo, nota_final, estado, fecha_evaluacion) VALUES
  (1, 10, 1, 1, 75.0, 'Aprobado', '2025-02-10'),
  (2, 11, 1, 1, 80.0, 'Aprobado', '2025-02-11'),
  (3, 18, 1, 1, 65.0, 'Aprobado', '2025-02-12'),
  (4, 10, 2, 1, 70.0, 'Aprobado', '2025-03-10'),
  (5, 11, 2, 1, 50.0, 'Reprobado', '2025-03-11'),
  (6, 16, 1, 2, 55.0, 'Reprobado', '2025-02-15'),
  (7, 17, 1, 2, 90.0, 'Aprobado', '2025-02-16'),
  (8, 12, 4, 3, 92.0, 'Aprobado', '2025-03-20'),
  (9, 13, 4, 3, 88.0, 'Aprobado', '2025-03-21'),
  (10, 13, 5, 3, 60.0, 'Reprobado', '2025-04-01'),
  (11, 14, 7, 5, 78.0, 'Aprobado', '2025-03-25'),
  (12, 15, 7, 5, 82.0, 'Aprobado', '2025-03-26'),
  (13, 20, 5, 3, 95.0, 'Aprobado', '2025-04-02');

-- 20. Detalle_Evaluacion 
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (1, 1, 1, 70.0, 'Bien en teoría'),
  (2, 1, 2, 80.0, 'Buen desempeño práctico'),
  (3, 1, 3, 75.0, 'Participación adecuada');
-- Evaluación id 2 (Módulo 1)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (4, 2, 1, 82.0, 'Sólido en teoría'),
  (5, 2, 2, 78.0, 'Buen trabajo en práctica'),
  (6, 2, 3, 80.0, 'Excelente participación');
-- Evaluación id 3 (Módulo 1)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (7, 3, 1, 60.0, 'Podría mejorar en teoría'),
  (8, 3, 2, 70.0, 'Poco en práctica'),
  (9, 3, 3, 65.0, 'Regular en quizzes');
-- Evaluación id 4 (Módulo 2: criterios 4,5,6)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (10, 4, 4, 72.0, 'Buena teoría en ML'),
  (11, 4, 5, 68.0, 'Práctica moderada'),
  (12, 4, 6, 70.0, 'Quizzes adecuados');
-- Evaluación id 5 (Módulo 2)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (13, 5, 4, 45.0, 'Teoría insuficiente'),
  (14, 5, 5, 55.0, 'Práctica baja'),
  (15, 5, 6, 50.0, 'Participación deficiente');
-- Evaluación id 6 (Módulo 1)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (16, 6, 1, 50.0, 'Muy baja teoría'),
  (17, 6, 2, 60.0, 'Baja práctica'),
  (18, 6, 3, 55.0, 'Participación baja');
-- Evaluación id 7 (Módulo 1)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (19, 7, 1, 95.0, 'Excelente en teoría'),
  (20, 7, 2, 85.0, 'Muy buena práctica'),
  (21, 7, 3, 90.0, 'Excelente participación');
-- Evaluación id 8 (Módulo 4: criterios 10,11,12)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (22, 8, 10, 93.0, 'Muy bueno en HTML & CSS (teoría)'),
  (23, 8, 11, 91.0, 'Competente en la parte práctica'),
  (24, 8, 12, 92.0, 'Quizzes excelentes');
-- Evaluación id 9 (Módulo 4)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (25, 9, 10, 88.0, 'Buena teoría en HTML & CSS'),
  (26, 9, 11, 86.0, 'Práctica aceptable'),
  (27, 9, 12, 89.0, 'Participación adecuada');
-- Evaluación id 10 (Módulo 5: criterios 13,14,15)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (28, 10, 13, 55.0, 'Teoría baja en JS'),
  (29, 10, 14, 60.0, 'Práctica baja en JS'),
  (30, 10, 15, 65.0, 'Quizzes moderados');
-- Evaluación id 11 (Módulo 7: criterios 19,20,21)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (31, 11, 19, 78.0, 'Bueno en teoría de seguridad'),
  (32, 11, 20, 80.0, 'Laboratorio adecuado'),
  (33, 11, 21, 76.0, 'Quizzes regulares');
-- Evaluación id 12 (Módulo 7)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (34, 12, 19, 85.0, 'Muy buena teoría en seguridad'),
  (35, 12, 20, 80.0, 'Buena práctica en laboratorio'),
  (36, 12, 21, 82.0, 'Participación destacada');
-- Evaluación id 13 (Módulo 5)
INSERT INTO detalle_evaluacion (id_detalle, id_evaluacion, id_criterio, nota, comentario) VALUES
  (37, 13, 13, 95.0, 'Excelente teoría en JS'),
  (38, 13, 14, 97.0, 'Excelente práctica en JS'),
  (39, 13, 15, 93.0, 'Quizzes sobresalientes');

-- 22. Historial de Estado de Camper
INSERT INTO historial_estado_camper (id_historial, id_camper, id_estado_anterior, id_estado_nuevo, fecha_cambio, razon_cambio, usuario_cambio) VALUES
  (1, 10, 2, 3, '2025-01-15 10:00:00', 'Aprobado tras evaluación', 'admin'),
  (2, 12, 3, 4, '2025-02-01 10:00:00', 'Inicio del curso', 'admin'),
  (3, 14, 4, 6, '2025-03-15 10:00:00', 'Infracción de normas', 'admin');


-- 1. Egresados
INSERT INTO egresados (id_camper, num_identificacion, nombres, apellidos, fecha_graduacion) VALUES
  (10, '100100100', 'Juan', 'Perez', '2025-04-15'),
  (11, '100200200', 'Maria', 'Gomez', '2025-04-15');

-- 2. Trainer_Conocimiento
-- Por ejemplo, el trainer con id 1 (Carlos) conoce los módulos 1 y 2,
-- el trainer con id 2 (Laura) conoce el módulo 4,
-- el trainer con id 3 (Pedro) conoce el módulo 7,
-- y el trainer con id 4 (Sergio) conoce el módulo 1.
INSERT INTO trainer_conocimiento (id_trainer, id_modulo) VALUES
  (1, 1),
  (1, 2),
  (2, 4),
  (3, 7),
  (4, 1);

-- 3. Salon_Asignacion
-- Asignamos salones para las rutas 1 y 2, por ejemplo:
INSERT INTO salon_asignacion (id_ruta, fecha_asignacion) VALUES
  (1, CURDATE()),
  (2, CURDATE());

-- 4. Notifications
-- Insertamos algunos mensajes de notificación de ejemplo.
INSERT INTO notifications (message, fecha) VALUES
  ('La ruta Data Science ha sido modificada.', CURDATE()),
  ('Se ha actualizado el horario en Sede Bogotá.', CURDATE());

-- 5. Asistencia
-- Registramos la asistencia en dos áreas: por ejemplo, el área 1 en el grupo 1 y el área 2 en el grupo 3.
INSERT INTO asistencia (id_area, id_grupo, fecha, total_asistentes) VALUES
  (1, 1, CURDATE(), 25),
  (2, 3, CURDATE(), 15);
