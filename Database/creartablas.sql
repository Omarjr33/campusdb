-- Crear la base de datos y seleccionarla
CREATE DATABASE IF NOT EXISTS db_camp;
USE db_camp;

-- Tabla ciudad (se utiliza en sede)
CREATE TABLE IF NOT EXISTS ciudad (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Tabla horario (utilizada en área de entrenamiento)
CREATE TABLE IF NOT EXISTS horario (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    jornada VARCHAR(50),
    hora_inicio TIME,
    hora_fin TIME
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS egresados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    num_identificacion VARCHAR(50),
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    fecha_graduacion DATE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS trainer_conocimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT,
    id_modulo INT,
    UNIQUE KEY (id_trainer, id_modulo)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS salon_asignacion (
    id_salon INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT,
    fecha_asignacion DATE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255),
    fecha DATE
) ENGINE=InnoDB;


-- Tabla sede (utiliza ciudad)
CREATE TABLE IF NOT EXISTS sede (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(50),
    email VARCHAR(100),
    id_ciudad INT,
    FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
) ENGINE=InnoDB;

-- Tabla estado_camper (independiente)
CREATE TABLE IF NOT EXISTS estado_camper (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(100) NOT NULL,
    nivel_riesgo VARCHAR(50)
) ENGINE=InnoDB;

-- Tabla ruta (independiente)
CREATE TABLE IF NOT EXISTS ruta (
    id_ruta INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_meses INT
) ENGINE=InnoDB;

-- Tabla área de entrenamiento (utiliza sede y horario)
CREATE TABLE IF NOT EXISTS area_entrenamiento (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    capacidad_max INT,
    ubicacion VARCHAR(255),
    id_sede INT,
    id_horario INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede),
    FOREIGN KEY (id_horario) REFERENCES horario(id_horario)
) ENGINE=InnoDB;

-- Tabla grupo (utiliza ruta y área de entrenamiento)
CREATE TABLE IF NOT EXISTS grupo (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_ruta INT,
    id_area INT,
    FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta),
    FOREIGN KEY (id_area) REFERENCES area_entrenamiento(id_area)
) ENGINE=InnoDB;

-- Tabla asistencia: registra la asistencia a clases por área y grupo
CREATE TABLE IF NOT EXISTS asistencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_area INT,
    id_grupo INT,
    fecha DATE,
    total_asistentes INT
) ENGINE=InnoDB;

-- Tabla camper (utiliza estado_camper, grupo y sede)
-- Se agrega el campo "acudiente" para almacenar el nombre del acudiente.
CREATE TABLE IF NOT EXISTS camper (
    id_camper INT AUTO_INCREMENT PRIMARY KEY,
    num_identificacion VARCHAR(50),
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    direccion VARCHAR(255),
    accidente VARCHAR(255),
    telefono VARCHAR(50),
    email VARCHAR(100),
    acudiente VARCHAR(100),
    fecha_nacimiento DATE,
    id_estado INT,
    id_grupo INT,
    id_sede INT,
    fecha_registro DATE,
    FOREIGN KEY (id_estado) REFERENCES estado_camper(id_estado),
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo),
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
) ENGINE=InnoDB;

-- Tabla modulo (independiente)
CREATE TABLE IF NOT EXISTS modulo (
    id_modulo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT,
    duracion_semanas INT,
    tipo VARCHAR(50)
) ENGINE=InnoDB;

-- Tabla criterio_evaluacion (usa modulo)
CREATE TABLE IF NOT EXISTS criterio_evaluacion (
    id_criterio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT,
    porcentaje DECIMAL(5,2),
    id_modulo INT,
    FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo)
) ENGINE=InnoDB;

-- Tabla tecnologia (usa modulo)
CREATE TABLE IF NOT EXISTS tecnologia (
    id_tecnologia INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT,
    id_modulo INT,
    FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo)
) ENGINE=InnoDB;

-- Tabla ruta_modulo (usa ruta y modulo)
CREATE TABLE IF NOT EXISTS ruta_modulo (
    id_ruta_modulo INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT,
    id_modulo INT,
    orden INT,
    FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta),
    FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo)
) ENGINE=InnoDB;

-- Tabla base_datos (usa ruta)
CREATE TABLE IF NOT EXISTS base_datos (
    id_bd INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    tipo VARCHAR(50),
    id_ruta INT,
    FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta)
) ENGINE=InnoDB;

-- Tabla trainer (usa sede)
CREATE TABLE IF NOT EXISTS trainer (
    id_trainer INT AUTO_INCREMENT PRIMARY KEY,
    num_identificacion VARCHAR(50),
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    especialidad VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(50),
    id_sede INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
) ENGINE=InnoDB;

-- Tabla trainer_grupo (usa trainer y grupo)
CREATE TABLE IF NOT EXISTS trainer_grupo (
    id_trainer_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT,
    id_grupo INT,
    fecha_asignacion DATE,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id_trainer),
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo)
) ENGINE=InnoDB;

-- Tabla trainer_modulo (usa trainer, modulo y grupo)
CREATE TABLE IF NOT EXISTS trainer_modulo (
    id_trainer_modulo INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT,
    id_modulo INT,
    id_grupo INT,
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id_trainer),
    FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo),
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo)
) ENGINE=InnoDB;

-- Tabla evaluacion_trainer (usa trainer, modulo y camper)
CREATE TABLE IF NOT EXISTS evaluacion_trainer (
    id_eval_trainer INT AUTO_INCREMENT PRIMARY KEY,
    id_trainer INT,
    id_modulo INT,
    id_camper INT,
    calificacion DECIMAL(5,2),
    comentarios TEXT,
    fecha_asignacion DATE,
    FOREIGN KEY (id_trainer) REFERENCES trainer(id_trainer),
    FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo),
    FOREIGN KEY (id_camper) REFERENCES camper(id_camper)
) ENGINE=InnoDB;

-- Tabla evaluacion_modulo (usa camper, modulo y grupo)
-- Se agrega la columna id_grupo para relacionarlo con la tabla grupo.
CREATE TABLE IF NOT EXISTS evaluacion_modulo (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    id_modulo INT,
    id_grupo INT,
    nota_final DECIMAL(5,2),
    estado VARCHAR(50),
    fecha_evaluacion DATE,
    FOREIGN KEY (id_camper) REFERENCES camper(id_camper),
    FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo),
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo)
) ENGINE=InnoDB;

-- Tabla detalle_evaluacion (usa evaluacion_modulo y criterio_evaluacion)
CREATE TABLE IF NOT EXISTS detalle_evaluacion (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_evaluacion INT,
    id_criterio INT,
    nota DECIMAL(5,2),
    comentario TEXT,
    FOREIGN KEY (id_evaluacion) REFERENCES evaluacion_modulo(id_evaluacion),
    FOREIGN KEY (id_criterio) REFERENCES criterio_evaluacion(id_criterio)
) ENGINE=InnoDB;

-- Tabla historial_estado_camper (usa camper y estado_camper para estados anterior y nuevo)
CREATE TABLE IF NOT EXISTS historial_estado_camper (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    id_estado_anterior INT,
    id_estado_nuevo INT,
    fecha_cambio DATETIME,
    razon_cambio TEXT,
    usuario_cambio VARCHAR(100),
    FOREIGN KEY (id_camper) REFERENCES camper(id_camper),
    FOREIGN KEY (id_estado_anterior) REFERENCES estado_camper(id_estado),
    FOREIGN KEY (id_estado_nuevo) REFERENCES estado_camper(id_estado)
) ENGINE=InnoDB;
