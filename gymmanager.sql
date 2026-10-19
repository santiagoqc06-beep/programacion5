-- ============================================================
-- GymManager - Tarea 2: script de base de datos
-- Tablas del modulo de Acceso: roles, usuarios, clientes, entrenadores
-- Motor: PostgreSQL
-- Antes de ejecutar: crear la base de datos (ej. CREATE DATABASE gymmanager;)
-- y conectarse a ella.
-- ============================================================

-- 1. LIMPIEZA: permite volver a ejecutar el script desde cero.
--    (Solo para desarrollo: borra las tablas y sus datos.)
DROP TABLE IF EXISTS entrenadores, clientes, usuarios, roles;

-- ============================================================
-- 2. CREACION DE TABLAS (primero las que no dependen de nadie)
-- ============================================================

-- ROLES: los cuatro roles del sistema.
CREATE TABLE roles (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(30)  NOT NULL UNIQUE,
    descripcion VARCHAR(150)
);

-- USUARIOS: datos de acceso de todas las personas del sistema.
CREATE TABLE usuarios (
    id             SERIAL PRIMARY KEY,
    rol_id         INTEGER      NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    nombre         VARCHAR(100) NOT NULL,
    apellido       VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    telefono       VARCHAR(20),
    activo         BOOLEAN      NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP    NOT NULL DEFAULT now()
);

-- CLIENTES: datos propios del cliente (relacion 1:1 con usuarios).
CREATE TABLE clientes (
    id               SERIAL PRIMARY KEY,
    usuario_id       INTEGER     NOT NULL UNIQUE REFERENCES usuarios(id) ON DELETE RESTRICT,
    tipo_documento   VARCHAR(5)  NOT NULL CHECK (tipo_documento IN ('CC', 'TI', 'CE', 'PA')),
    documento        VARCHAR(20) NOT NULL UNIQUE,
    fecha_nacimiento DATE        NOT NULL
);

-- ENTRENADORES: datos propios del entrenador (relacion 1:1 con usuarios).
CREATE TABLE entrenadores (
    id                 SERIAL PRIMARY KEY,
    usuario_id         INTEGER      NOT NULL UNIQUE REFERENCES usuarios(id) ON DELETE RESTRICT,
    especialidad       VARCHAR(100) NOT NULL,
    fecha_contratacion DATE
);

-- ============================================================
-- 3. DATOS DE PRUEBA
-- Los ids se generan en orden (1, 2, 3...) porque las tablas se acaban de crear.
-- Los password_hash son TEXTOS DE PRUEBA, no son hashes reales.
-- ============================================================

INSERT INTO roles (nombre, descripcion) VALUES
    ('Administrador', 'Gestiona todo el sistema'),
    ('Recepcionista', 'Registra pagos, ingresos y atiende a los clientes'),
    ('Entrenador',    'Crea rutinas y planes de alimentacion'),
    ('Cliente',       'Miembro del gimnasio');

-- rol_id: 1 = Administrador, 2 = Recepcionista, 3 = Entrenador, 4 = Cliente
INSERT INTO usuarios (rol_id, nombre, apellido, email, password_hash, telefono) VALUES
    (1, 'Laura',   'Gomez',    'laura.gomez@gymmanager.test',    'hash_de_prueba_1', '3001110001'),
    (2, 'Camilo',  'Rojas',    'camilo.rojas@gymmanager.test',   'hash_de_prueba_2', '3001110002'),
    (3, 'Andres',  'Castano',  'andres.castano@gymmanager.test', 'hash_de_prueba_3', '3001110003'),
    (3, 'Daniela', 'Mejia',    'daniela.mejia@gymmanager.test',  'hash_de_prueba_4', '3001110004'),
    (4, 'Sofia',   'Herrera',  'sofia.herrera@gymmanager.test',  'hash_de_prueba_5', '3001110005'),
    (4, 'Juan',    'Ortiz',    'juan.ortiz@gymmanager.test',     'hash_de_prueba_6', '3001110006'),
    (4, 'Valeria', 'Cardenas', 'valeria.cardenas@gymmanager.test', 'hash_de_prueba_7', NULL);

-- usuarios 5, 6 y 7 son los clientes
INSERT INTO clientes (usuario_id, tipo_documento, documento, fecha_nacimiento) VALUES
    (5, 'CC', '1005000001', '1998-03-14'),
    (6, 'CC', '1005000002', '2001-11-02'),
    (7, 'TI', '1105000003', '2008-07-21');

-- usuarios 3 y 4 son los entrenadores
INSERT INTO entrenadores (usuario_id, especialidad, fecha_contratacion) VALUES
    (3, 'Musculacion y fuerza',       '2024-02-01'),
    (4, 'Funcional y cardio',         '2025-06-15');

-- ============================================================
-- 4. VERIFICACION (opcional): consulta que une las tablas
-- ============================================================
-- SELECT c.id, u.nombre, u.apellido, r.nombre AS rol, c.documento
-- FROM clientes c
-- JOIN usuarios u ON u.id = c.usuario_id
-- JOIN roles r    ON r.id = u.rol_id;

-- ============================================================
-- 5. PRUEBAS DE ERRORES ESPERADOS (descomentar de a una)
-- ============================================================
-- Email repetido (viola UNIQUE):
--   INSERT INTO usuarios (rol_id, nombre, apellido, email, password_hash)
--   VALUES (4, 'X', 'Y', 'laura.gomez@gymmanager.test', 'x');
-- Rol que no existe (viola FOREIGN KEY):
--   INSERT INTO usuarios (rol_id, nombre, apellido, email, password_hash)
--   VALUES (99, 'X', 'Y', 'nuevo@gymmanager.test', 'x');
-- Tipo de documento invalido (viola CHECK):
--   INSERT INTO clientes (usuario_id, tipo_documento, documento, fecha_nacimiento)
--   VALUES (1, 'ZZ', '999', '2000-01-01');
-- Borrar un rol que esta en uso (bloqueado por ON DELETE RESTRICT):
--   DELETE FROM roles WHERE id = 4;