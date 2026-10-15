-- TutoresOn-Line: esquema de base de datos (PostgreSQL)

CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  correo VARCHAR(160) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  rol VARCHAR(10) NOT NULL CHECK (rol IN ('estudiante','tutor')),
  nivel_educativo VARCHAR(40),
  telefono VARCHAR(20),
  correo_verificado BOOLEAN DEFAULT FALSE,
  creado_en TIMESTAMP DEFAULT NOW()
);

CREATE TABLE perfiles_tutor (
  id SERIAL PRIMARY KEY,
  usuario_id INT UNIQUE NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  biografia TEXT,
  tarifa_hora NUMERIC(10,2) NOT NULL,
  zona VARCHAR(80),
  verificado BOOLEAN DEFAULT FALSE,
  disponible_ahora BOOLEAN DEFAULT FALSE,
  promedio NUMERIC(2,1) DEFAULT 0,
  total_resenas INT DEFAULT 0
);

CREATE TABLE materias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE tutor_materias (
  tutor_id INT REFERENCES perfiles_tutor(id) ON DELETE CASCADE,
  materia_id INT REFERENCES materias(id),
  PRIMARY KEY (tutor_id, materia_id)
);

CREATE TABLE disponibilidad (
  id SERIAL PRIMARY KEY,
  tutor_id INT NOT NULL REFERENCES perfiles_tutor(id) ON DELETE CASCADE,
  dia_semana SMALLINT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL
);

CREATE TABLE reservas (
  id SERIAL PRIMARY KEY,
  estudiante_id INT NOT NULL REFERENCES usuarios(id),
  tutor_id INT NOT NULL REFERENCES perfiles_tutor(id),
  materia_id INT NOT NULL REFERENCES materias(id),
  inicio TIMESTAMP NOT NULL,
  duracion_min INT DEFAULT 60,
  modalidad VARCHAR(10) CHECK (modalidad IN ('virtual','presencial')),
  estado VARCHAR(12) DEFAULT 'pendiente'
    CHECK (estado IN ('pendiente','aceptada','rechazada','finalizada','cancelada')),
  es_modo_ahora BOOLEAN DEFAULT FALSE,
  enlace_video TEXT
);

CREATE TABLE pagos (
  id SERIAL PRIMARY KEY,
  reserva_id INT UNIQUE NOT NULL REFERENCES reservas(id),
  monto NUMERIC(10,2) NOT NULL,
  metodo VARCHAR(20),
  estado VARCHAR(12) DEFAULT 'pendiente',
  pagado_en TIMESTAMP
);

CREATE TABLE resenas (
  id SERIAL PRIMARY KEY,
  reserva_id INT NOT NULL REFERENCES reservas(id),
  autor_id INT NOT NULL REFERENCES usuarios(id),
  destinatario_id INT NOT NULL REFERENCES usuarios(id),
  calificacion SMALLINT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
  etiquetas TEXT[],
  comentario TEXT,
  UNIQUE (reserva_id, autor_id)
);

CREATE TABLE notificaciones (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL REFERENCES usuarios(id),
  canal VARCHAR(10) CHECK (canal IN ('correo','sms','whatsapp','push')),
  mensaje TEXT NOT NULL,
  enviada_en TIMESTAMP DEFAULT NOW()
);
