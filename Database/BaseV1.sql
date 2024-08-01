--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

-- Started on 2024-02-23 09:35:43

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 18082)
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- TOC entry 264 (class 1255 OID 18089)
-- Name: actualizar_datos_familiares(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_datos_familiares() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Manejar la inserción
    IF TG_OP = 'INSERT' THEN
		IF EXISTS (select 1 from paciente where dni = new.dni_paciente) THEN
			INSERT INTO Persona (dni, CUIL, nombre, apellido, ciudad, calle, numero, depto, email, fecha_nac, rol)
			VALUES (NEW.dni, NEW.CUIL, NEW.nombre, NEW.apellido, NEW.ciudad, NEW.calle, NEW.numero, NEW.depto, NEW.email, NEW.fecha_nac, 'N');
   
			IF NOT EXISTS (select 1 from cobertura_social where nombre = new.nombre_cobertura_social) THEN
				INSERT INTO Cobertura_social(nombre) VALUES (new.nombre_cobertura_social);
			END IF;
			
			INSERT INTO No_voluntario(dni, tipo, nombre_cobertura_social, nro_afiliado, descripcion)
			VALUES (new.dni, 'F', new.nombre_cobertura_social, new.nro_afiliado, new.descripcion);
			
			INSERT INTO Familiar(dni) 
			VALUES (new.dni);
			
			INSERT INTO es_pariente(dni_familiar, dni_paciente, relacion) 
			VALUES (new.dni, new.dni_paciente, new.relacion);
			
			INSERT INTO telefono (dni, telefono)
			VALUES (new.dni, new.telefono);
		ELSE
			RAISE EXCEPTION 'No existe el paciente';
		END IF;
        RETURN NEW;
    END IF;

    -- Manejar la actualización
    IF TG_OP = 'UPDATE' THEN
		IF EXISTS (select 1 from persona p where p.dni = new.dni) then
			UPDATE Persona
			SET nombre = NEW.nombre, apellido = NEW.apellido, ciudad = NEW.ciudad,
				calle = NEW.calle, numero = NEW.numero, depto = NEW.depto, email = NEW.email, fecha_nac = NEW.fecha_nac
			WHERE dni = NEW.dni;
			
			IF NOT EXISTS (select 1 from cobertura_social where nombre = new.nombre_cobertura_social) THEN
				INSERT INTO Cobertura_social(nombre) VALUES (new.nombre_cobertura_social);
			END IF;
			
			UPDATE No_voluntario
			SET nro_afiliado = NEW.nro_afiliado, descripcion = NEW.descripcion, nombre_cobertura_social= new.nombre_cobertura_social
			WHERE dni = NEW.dni;
			
			UPDATE Telefono
			SET telefono = new.telefono
			WHERE dni = NEW.dni;
			
			UPDATE es_pariente
			SET relacion = new.relacion
			WHERE dni_familiar = NEW.dni;
			
			RETURN NEW;
		ELSE 
		    RAISE EXCEPTION 'No existe el familiar que desea modificar';
		END IF;
    END IF;

    -- Manejar la eliminación
    IF TG_OP = 'DELETE' THEN
		DELETE FROM es_pariente WHERE dni_familiar = OLD.dni;
		DELETE FROM familiar WHERE dni = OLD.dni;
		DELETE FROM telefono WHERE dni = OLD.dni;
        DELETE FROM No_voluntario WHERE dni = OLD.dni;
		DELETE FROM Persona WHERE dni = OLD.dni;
        RETURN OLD;
    END IF;
	
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.actualizar_datos_familiares() OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 18090)
-- Name: actualizar_datos_pacientes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_datos_pacientes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN
    -- Manejar la inserción
    IF TG_OP = 'INSERT' THEN
        INSERT INTO Persona (dni, CUIL, nombre, apellido, ciudad, calle, numero, depto, email, 
							 fecha_nac, rol)
        VALUES (NEW.dni, NEW.CUIL, NEW.nombre, NEW.apellido, NEW.ciudad, NEW.calle, NEW.numero,
				NEW.depto, NEW.email, NEW.fecha_nac, 'N');
        IF (new.nombre_cobertura_social is not null) THEN
			IF NOT EXISTS (select 1 from cobertura_social where nombre = new.nombre_cobertura_social) THEN
				INSERT INTO Cobertura_social(nombre) VALUES (new.nombre_cobertura_social);
			END IF;
		END IF;
		INSERT INTO No_voluntario(dni, tipo, nombre_cobertura_social, nro_afiliado, descripcion)
		VALUES (new.dni,'P', new.nombre_cobertura_social, new.nro_afiliado, new.descripcion);
		INSERT INTO Paciente(dni,legajo_proceso_salud, legajo_socioeconomico) 
		VALUES (new.dni,new.legajo_proceso_salud, new.legajo_socioeconomico);

        RETURN NEW;
    END IF;

    -- Manejar la actualización
    IF TG_OP = 'UPDATE' THEN
		IF EXISTS (select 1 from persona p where p.dni = new.dni) then
			UPDATE Persona
			SET nombre = NEW.nombre, apellido = NEW.apellido, ciudad = NEW.ciudad,
				calle = NEW.calle, numero = NEW.numero, depto = NEW.depto, email = NEW.email, fecha_nac = NEW.fecha_nac
			WHERE dni = NEW.dni;
			IF (new.nombre_cobertura_social is not null) THEN
				IF NOT EXISTS (select 1 from cobertura_social where nombre = new.nombre_cobertura_social) THEN
					INSERT INTO Cobertura_social(nombre) VALUES (new.nombre_cobertura_social);
				END IF;
			END IF;
			
			UPDATE No_voluntario
			SET nro_afiliado = NEW.nro_afiliado, descripcion = NEW.descripcion, nombre_cobertura_social= new.nombre_cobertura_social
			WHERE dni = NEW.dni;
			
			UPDATE Paciente
			SET legajo_socioeconomico = NEW.legajo_socieconomico, legajo_proceso_salud = NEW.legajo_proceso_salud
			WHERE dni = NEW.dni;
			
			RETURN NEW;
		ELSE 
		    RAISE EXCEPTION 'No existe el paciente que desea modificar';
		END IF;
    END IF;

    -- Manejar la eliminación
    IF TG_OP = 'DELETE' THEN
		DELETE FROM persona where dni IN (select dni_familiar from es_pariente where dni_paciente = old.dni);
		DELETE FROM es_pariente WHERE dni_paciente = OLD.dni;
		DELETE FROM Paciente WHERE dni = OLD.dni;
        DELETE FROM No_voluntario WHERE dni = OLD.dni;
		DELETE FROM Persona WHERE dni = OLD.dni;
        RETURN OLD;
    END IF;
	
    RETURN NULL;
END;

$$;


ALTER FUNCTION public.actualizar_datos_pacientes() OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 18091)
-- Name: actualizar_datos_sede(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_datos_sede() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Manejar la inserción
    IF TG_OP = 'INSERT' THEN
		IF EXISTS (select 1 from institucion where id_institucion = new.id_institucion) THEN
			INSERT INTO Sede(id_sede, id_institucion, ciudad, calle, numero, email, horario)
			VALUES (new.id_sede, new.id_institucion, new.ciudad, new.calle, new.numero, new.email, new.horario);

			INSERT INTO telefono_sede (id_sede, id_institucion, telefono)
			VALUES (new.id_sede, new.id_institucion, new.telefono);
		ELSE
			RAISE EXCEPTION 'No existe la institucion a la que pertenece la sede';
		END IF;
        RETURN NEW;
    END IF;

    -- Manejar la actualización
    IF TG_OP = 'UPDATE' THEN
		IF EXISTS (select 1 from sede s 
				   where (s.id_sede = new.id_sede) and (s.id_institucion = new.id_institucion)) then
			UPDATE Sede
			SET ciudad = NEW.ciudad,calle = NEW.calle, numero = NEW.numero, email = NEW.email, horario = new.horario;
			
			UPDATE Telefono_sede
			SET telefono = new.telefono
			WHERE id_sede = NEW.id_sede and id_institucion = new.id_institucion;
			
			RETURN NEW;
		ELSE 
		    RAISE EXCEPTION 'No existe la sede que desea modificar';
		END IF;
    END IF;

    -- Manejar la eliminación
    IF TG_OP = 'DELETE' THEN
		DELETE FROM telefono_sede WHERE id_sede = old.id_sede and id_institucion = old.id_institucion;
		DELETE FROM sede WHERE  id_sede = old.id_sede and id_institucion = old.id_institucion;
        RETURN OLD;
    END IF;
	
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.actualizar_datos_sede() OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 18092)
-- Name: actualizar_datos_voluntarios(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_datos_voluntarios() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
    -- Manejar la inserción
    IF TG_OP = 'INSERT' THEN
        INSERT INTO Persona (dni, CUIL, nombre, apellido, ciudad, calle, numero, depto, email, fecha_nac, rol)
        VALUES (NEW.dni, NEW.CUIL, NEW.nombre, NEW.apellido, NEW.ciudad, NEW.calle, NEW.numero, NEW.depto, NEW.email, NEW.fecha_nac, 'V');
        INSERT INTO Voluntario(dni,tipo, password, created_at, updated_at, remember_token, id) 
		VALUES (new.dni,'P', new.password, new.created_at, new.updated_at, new.remember_token, new.id);

        RETURN NEW;
    END IF;
	
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.actualizar_datos_voluntarios() OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 18093)
-- Name: actualizar_datos_voluntarios_no_profesionales(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_datos_voluntarios_no_profesionales() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	dni_user int;
BEGIN
    -- Manejar la inserción
    IF TG_OP = 'INSERT' THEN
        INSERT INTO Persona (dni, CUIL, nombre, apellido, ciudad, calle, numero, depto, email, fecha_nac, rol)
        VALUES (NEW.dni, NEW.CUIL, NEW.nombre, NEW.apellido, NEW.ciudad, NEW.calle, NEW.numero, NEW.depto, NEW.email, NEW.fecha_nac, 'V');
        INSERT INTO Voluntario(dni,tipo,id) 
		VALUES (new.dni,'N',new.id);
		INSERT INTO NO_profesional(dni, area_desarrollo) 
		VALUES (new.dni, new.area_desarrollo);
		
		IF (new.capacitacion is not null) then
			INSERT INTO Capacitacion (dni, capacitacion, fecha, otorgado_por)
			VALUES (NEW.dni, NEW.capacitacion, NEW.fecha, NEW.otorgado_por);
		END IF;
		IF (new.oficio is not null) then
			INSERT INTO Oficio (dni, oficio)
			VALUES (NEW.dni, NEW.oficio);
		END IF;
		
		INSERT INTO Telefono(dni, telefono) 
		VALUES (new.dni, new.telefono);
		
		
		
        RETURN NEW;
    END IF;

    -- Manejar la actualización
    IF TG_OP = 'UPDATE' THEN
		IF EXISTS (select 1 from persona p where p.dni = new.dni) then
			UPDATE Persona
			SET nombre = NEW.nombre, apellido = NEW.apellido, ciudad = NEW.ciudad,
				calle = NEW.calle, numero = NEW.numero, depto = NEW.depto, email = NEW.email, fecha_nac = NEW.fecha_nac
			WHERE dni = NEW.dni;

			UPDATE Capacitacion
			SET capacitacion = NEW.capacitacion, fecha = NEW.fecha, otorgado_por = NEW.otorgado_por
			WHERE dni = NEW.dni;

			UPDATE Oficio
			SET oficio = NEW.oficio
			WHERE dni = NEW.dni;
			
			UPDATE Telefono
			SET telefono = NEW.telefono
			WHERE dni = NEW.dni;
			
			RETURN NEW;
		ELSE 
		    RAISE EXCEPTION 'No existe el voluntario no profesional que desea modificar';
		END IF;
    END IF;

    -- Manejar la eliminación
    IF TG_OP = 'DELETE' THEN
		DELETE FROM Telefono WHERE dni = OLD.dni;
		DELETE FROM Oficio WHERE dni = OLD.dni;
		DELETE FROM Capacitacion WHERE dni = OLD.dni;
		DELETE FROM No_profesional WHERE dni = OLD.dni;
        DELETE FROM Voluntario WHERE dni = OLD.dni;
		DELETE FROM Persona WHERE dni = OLD.dni;
        RETURN OLD;
    END IF;
	
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.actualizar_datos_voluntarios_no_profesionales() OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 18094)
-- Name: actualizar_datos_voluntarios_profesionales(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_datos_voluntarios_profesionales() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
    -- Manejar la inserción
    IF TG_OP = 'INSERT' THEN
        INSERT INTO Persona (dni, CUIL, nombre, apellido, ciudad, calle, numero, depto, email, fecha_nac, rol)
        VALUES (NEW.dni, NEW.CUIL, NEW.nombre, NEW.apellido, NEW.ciudad, NEW.calle, NEW.numero, NEW.depto, NEW.email, NEW.fecha_nac, 'V');
        INSERT INTO Voluntario(dni,tipo, id) 
		VALUES (new.dni,'P', new.id);
		INSERT INTO Profesional(dni) 
		VALUES (new.dni);
        INSERT INTO Titulo (dni, titulo, tipo_titulo)
        VALUES (NEW.dni, NEW.titulo, NEW.tipo_titulo);
		INSERT INTO Telefono(dni, telefono) 
		VALUES (new.dni, new.telefono);
	
        RETURN NEW;
    END IF;

    -- Manejar la actualización
    IF TG_OP = 'UPDATE' THEN
		IF EXISTS (select 1 from persona p where p.dni = new.dni) then
			UPDATE Persona
			SET nombre = NEW.nombre, apellido = NEW.apellido, ciudad = NEW.ciudad,
				calle = NEW.calle, numero = NEW.numero, depto = NEW.depto, email = NEW.email, fecha_nac = NEW.fecha_nac
			WHERE dni = NEW.dni;

			UPDATE Titulo
			SET titulo = NEW.titulo, tipo_titulo = NEW.tipo_titulo
			WHERE dni = NEW.dni;
			
			UPDATE Telefono
			SET telefono = NEW.telefono
			WHERE dni = NEW.dni;

			RETURN NEW;
		ELSE 
		    RAISE EXCEPTION 'No existe el voluntario profesional que desea modificar';
		END IF;
    END IF;

    -- Manejar la eliminación
    IF TG_OP = 'DELETE' THEN
		DELETE FROM Telefono WHERE dni = old.dni;
		DELETE FROM Titulo WHERE dni = OLD.dni;
		DELETE FROM Profesional WHERE dni = OLD.dni;
		DELETE FROM Voluntario WHERE dni = OLD.dni;
		DELETE FROM Persona WHERE dni = OLD.dni;
		RETURN OLD;
    END IF;
	
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.actualizar_datos_voluntarios_profesionales() OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 18095)
-- Name: buscar_atendido_por(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_atendido_por(nombre_profesional character varying, apellido_profesional character varying) RETURNS TABLE(nombre_paciente character varying, apellido_paciente character varying, dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, relacion character varying, telefono character varying, cobertura_social character varying, nro_afiliado integer, legajo_proceso_salud character varying, legajo_socioeconomico character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p2.nombre, p2.apellido, p2.dni, p2.cuil, p2.ciudad, p2.calle, p2.numero, p2.depto, p2.email,p2.fecha_nac, e.relacion, t.telefono, v.nombre_cobertura_social, v.nro_afiliado, c.legajo_proceso_salud, c.legajo_socioeconomico
	FROM persona p 
	join atiende a on (a.dni_profesional = p.dni)
	join persona p2 on (p2.dni= a.dni_paciente)
	join no_voluntario v on (v.dni = p2.dni)
	left join es_pariente e on (p2.dni = e.dni_paciente)
 	left join telefono t on (t.dni = e.dni_familiar)
	join paciente c on (p2.dni = c.dni)
	where LOWER(unaccent(nombre_profesional)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(apellido_profesional)) = LOWER(unaccent(p.apellido));
END;
$$;


ALTER FUNCTION public.buscar_atendido_por(nombre_profesional character varying, apellido_profesional character varying) OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 18096)
-- Name: buscar_atiende_a(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_atiende_a(nombre_paciente character varying, apellido_paciente character varying) RETURNS TABLE(dni_paciente bigint, nombre_profesional character varying, apellido_profesional character varying, dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, tipo_titulo character varying, titulo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, p2.nombre, p2.apellido, p2.dni, p2.cuil, p2.ciudad, p2.calle, p2.numero, p2.depto, p2.email, p2.fecha_nac, t.telefono, u.tipo_titulo, u.titulo
	FROM persona p 
	join atiende a on (a.dni_paciente = p.dni)
	join persona p2 on (p2.dni= a.dni_profesional)
	join telefono t on (t.dni = p2.dni)
	join titulo u on (u.dni = p2.dni)
	where LOWER(unaccent(nombre_paciente)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(apellido_paciente)) = LOWER(unaccent(p.apellido));
END;
$$;


ALTER FUNCTION public.buscar_atiende_a(nombre_paciente character varying, apellido_paciente character varying) OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 18097)
-- Name: buscar_familiares(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_familiares(nombre_paciente character varying, apellido_paciente character varying) RETURNS TABLE(dni_paciente bigint, relacion character varying, nombre character varying, apellido character varying, dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, cobertura_social character varying, nro_afiliado integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, e.relacion, p2.nombre, p2.apellido, p2.dni, p2.cuil, p2.ciudad, p2.calle, p2.numero, p2.depto, p2.email, p2.fecha_nac, t.telefono,v.nombre_cobertura_social, v.nro_afiliado, v.descripcion
	FROM persona p 
	join es_pariente e on (e.dni_paciente = p.dni)
	join persona p2 on (p2.dni= e.dni_familiar)
	join telefono t on (t.dni = p2.dni)
	join no_voluntario v on (v.dni = p2.dni)
	where LOWER(unaccent(nombre_paciente)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(apellido_paciente)) = LOWER(unaccent(p.apellido));
END;
$$;


ALTER FUNCTION public.buscar_familiares(nombre_paciente character varying, apellido_paciente character varying) OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 18098)
-- Name: buscar_paciente(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_paciente(var_nombre character varying, var_apellido character varying) RETURNS TABLE(dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, legajo_proceso_salud character varying, legajo_socieconomico character varying, cobertura_social character varying, nro_afiliado integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, p.cuil, p.ciudad, p.calle, p.numero, p.depto, p.email, p.fecha_nac, t.telefono, a.legajo_socioeconomico, a.legajo_proceso_salud ,v.nombre_cobertura_social, v.nro_afiliado, v.descripcion
	FROM persona p left join telefono t on (p.dni = t.dni) join no_voluntario v on (v.dni = p.dni) join paciente a on (a.dni = p.dni)
	where LOWER(unaccent(var_nombre)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(var_apellido)) = LOWER(unaccent(p.apellido));
END;
$$;


ALTER FUNCTION public.buscar_paciente(var_nombre character varying, var_apellido character varying) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 18099)
-- Name: buscar_participa_en_servicio(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_participa_en_servicio(nombre character varying, apellido character varying) RETURNS TABLE(dni_voluntario bigint, nombre_servicio character varying, id_sede integer, ciudad character varying, calle character varying, numero integer, telefono character varying, horario character varying, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, s.nombre, s.id_sede, e.ciudad, e.calle, e.numero, t.telefono, e.horario, e.email
	FROM persona p 
	join colabora c on (c.dni = p.dni)
	join servicio s on (s.id_servicio = c.id_servicio) and (s.id_sede = c.id_sede) and (s.id_institucion = c.id_institucion)
	join sede e on (e.id_sede = s.id_sede) and (s.id_institucion = e.id_institucion)
	join telefono_sede t on (e.id_sede = t.id_sede) and (s.id_institucion = t.id_institucion)
	where LOWER(unaccent(nombre)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(apellido)) = LOWER(unaccent(p.apellido));
END;
$$;


ALTER FUNCTION public.buscar_participa_en_servicio(nombre character varying, apellido character varying) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 18100)
-- Name: buscar_voluntario_no_profesional(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_voluntario_no_profesional(var_nombre character varying, var_apellido character varying) RETURNS TABLE(dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, oficio character varying, capacitacion character varying, fecha date, otorgado_por character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, p.cuil, p.ciudad, p.calle, p.numero, p.depto, p.email, p.fecha_nac, t.telefono, o.oficio, c.capacitacion, c.fecha, c.otorgado_por
	FROM persona p left join telefono t on (p.dni = t.dni) left join oficio o on (o.dni = p.dni) left join capacitacion c on (c.dni = p.dni)
	where LOWER(unaccent(var_nombre)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(var_apellido)) = LOWER(unaccent(p.apellido));
END;
$$;


ALTER FUNCTION public.buscar_voluntario_no_profesional(var_nombre character varying, var_apellido character varying) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 18101)
-- Name: buscar_voluntario_profesional(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_voluntario_profesional(var_nombre character varying, var_apellido character varying) RETURNS TABLE(dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, tipo_titulo character varying, titulo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, p.cuil, p.ciudad, p.calle, p.numero, p.depto, p.email, p.fecha_nac, t.telefono, i.tipo_titulo, i.titulo
	FROM persona p left join telefono t on (p.dni = t.dni) left join titulo i on (i.dni = p.dni)
	where LOWER(unaccent(var_nombre)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(var_apellido)) = LOWER(unaccent(p.apellido));
END;
$$;


ALTER FUNCTION public.buscar_voluntario_profesional(var_nombre character varying, var_apellido character varying) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 18102)
-- Name: cambio_ciudad(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cambio_ciudad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS ( --si esta agregado en colabora es poque las ciudades coinciden, entonces si la quiero cambiar, dejarian de coincidir
      SELECT 1
      FROM colabora c
      where c.dni = new.dni
  ) THEN
    RAISE EXCEPTION 'No se puede actualizar la ciudad, ya que el voluntario colabora en servicios en sede';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.cambio_ciudad() OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 18103)
-- Name: cambio_ciudad_sede(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cambio_ciudad_sede() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM colabora c
      where (c.id_sede = new.id_sede) and (c.id_institucion = new.id_institucion)
  ) THEN
    RAISE EXCEPTION 'No se puede actualizar la ciudad, ya que hay voluntarios colaborando en la sede';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.cambio_ciudad_sede() OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 18104)
-- Name: insert_colabora(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_colabora() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  ciudad_sede varchar(50);
  ciudad_vol varchar(50);
BEGIN
  SELECT s.ciudad INTO ciudad_sede 
  FROM sede s
  where (s.id_sede = new.id_sede) and (s.id_institucion = new.id_institucion);
  
  select p.ciudad INTO ciudad_vol
  FROM Persona p 
  where (p.dni = new.dni);
  
  IF (UPPER(ciudad_sede) <> UPPER(ciudad_vol)) THEN
    RAISE EXCEPTION 'El voluntario no puede colaborar en el servicio ya que son de ciudades distintas';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.insert_colabora() OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 18105)
-- Name: insert_familiar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_familiar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM paciente p
      where (p.dni = new.dni)
  ) THEN
    RAISE EXCEPTION 'Esta persona es un paciente';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.insert_familiar() OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 18106)
-- Name: insert_no_profesional(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_no_profesional() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM profesional p
      where (p.dni = new.dni)
  ) THEN
    RAISE EXCEPTION 'Esta persona es un voluntario profesional';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.insert_no_profesional() OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 18107)
-- Name: insert_no_voluntario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_no_voluntario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM voluntario v
      where (v.dni = new.dni)
  ) THEN
    RAISE EXCEPTION 'Esta persona es un voluntario';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.insert_no_voluntario() OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 18108)
-- Name: insert_paciente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_paciente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM familiar f
      where (f.dni = new.dni)
  ) THEN
    RAISE EXCEPTION 'Esta persona es un familiar';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.insert_paciente() OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 18109)
-- Name: insert_profesional(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_profesional() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM no_profesional n
      where (n.dni = new.dni)
  ) THEN
    RAISE EXCEPTION 'Esta persona es un voluntario no profesional';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.insert_profesional() OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 18110)
-- Name: insert_voluntario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_voluntario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM no_voluntario n
      where (n.dni = new.dni)
  ) THEN
    RAISE EXCEPTION 'Esta persona esta en el sistema como paciente o familiar';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.insert_voluntario() OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 18111)
-- Name: max_voluntarios_colabora(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.max_voluntarios_colabora() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cant_voluntarios INT;
  max_voluntarios INT;
BEGIN
  -- Obtener la cantidad actual de voluntarios para el servicio
  SELECT COUNT(*) INTO cant_voluntarios
  FROM colabora
  WHERE (id_servicio = new.id_servicio) and (id_sede = new.id_sede) and (id_institucion = new.id_institucion);

  -- Obtener la cantidad máxima de voluntarios permitidos para el servicio
  SELECT max_personas INTO max_voluntarios
  FROM servicio
  WHERE (id_servicio = new.id_servicio) and (id_sede = new.id_sede) and (id_institucion = new.id_institucion);

  -- Verificar si se supera la cantidad máxima
  IF cant_voluntarios >= max_voluntarios THEN
    RAISE EXCEPTION 'Se supera la cantidad máxima de voluntarios que pueden colaborar en el servicio';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.max_voluntarios_colabora() OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 18112)
-- Name: max_voluntarios_servicio(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.max_voluntarios_servicio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM colabora c 
      where (c.id_servicio = new.id_servicio) and (c.id_sede = new.id_sede) and (c.id_institucion = new.id_institucion)
      GROUP BY c.id_servicio, c.id_sede, c.id_institucion
	  having count(*) > new.max_personas
  ) THEN
    RAISE EXCEPTION 'No es posible modificar la cantidad maxima de voluntarios, porque ya hay voluntarios colaborando';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.max_voluntarios_servicio() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 18113)
-- Name: atiende; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.atiende (
    dni_paciente integer NOT NULL,
    dni_profesional integer NOT NULL
);


ALTER TABLE public.atiende OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 18116)
-- Name: capacitacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.capacitacion (
    capacitacion character varying(100) NOT NULL,
    fecha timestamp without time zone,
    otorgado_por character varying(50),
    dni integer NOT NULL
);


ALTER TABLE public.capacitacion OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 18119)
-- Name: cobertura_social; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cobertura_social (
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.cobertura_social OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 18122)
-- Name: colabora; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.colabora (
    id_servicio integer NOT NULL,
    dni integer NOT NULL,
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL
);


ALTER TABLE public.colabora OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 18418)
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    "fullName" character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 18417)
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO postgres;

--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 254
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- TOC entry 220 (class 1259 OID 18125)
-- Name: no_profesional; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.no_profesional (
    area_desarrollo character varying(20) NOT NULL,
    dni integer NOT NULL
);


ALTER TABLE public.no_profesional OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 18128)
-- Name: oficio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oficio (
    oficio character varying(20) NOT NULL,
    dni integer NOT NULL
);


ALTER TABLE public.oficio OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 18131)
-- Name: persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona (
    dni bigint NOT NULL,
    cuil bigint NOT NULL,
    nombre character varying(15) NOT NULL,
    apellido character varying(15) NOT NULL,
    ciudad character varying(15) NOT NULL,
    calle character varying(20) NOT NULL,
    numero integer NOT NULL,
    depto character varying(2),
    email character varying(40) NOT NULL,
    fecha_nac date NOT NULL,
    rol character varying(1) NOT NULL
);


ALTER TABLE public.persona OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 18134)
-- Name: telefono; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telefono (
    dni integer NOT NULL,
    telefono character varying(20) NOT NULL
);


ALTER TABLE public.telefono OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18137)
-- Name: voluntario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voluntario (
    tipo character varying(1) NOT NULL,
    dni integer NOT NULL,
    remember_token character varying(100),
    id bigint
);


ALTER TABLE public.voluntario OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18140)
-- Name: datos_basicos_voluntarios_no_profesionales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.datos_basicos_voluntarios_no_profesionales AS
 SELECT d.nombre,
    d.apellido,
    d.dni,
    d.cuil,
    d.ciudad,
    d.calle,
    d.numero,
    d.depto,
    d.email,
    d.fecha_nac,
    t.telefono,
    n.area_desarrollo,
    o.oficio,
    c.capacitacion,
    c.fecha,
    c.otorgado_por,
    v.id
   FROM (((((public.persona d
     JOIN public.voluntario v ON ((v.dni = d.dni)))
     JOIN public.no_profesional n ON ((d.dni = n.dni)))
     JOIN public.telefono t ON ((t.dni = d.dni)))
     LEFT JOIN public.oficio o ON ((n.dni = o.dni)))
     LEFT JOIN public.capacitacion c ON ((c.dni = n.dni)))
  ORDER BY d.nombre, d.apellido;


ALTER VIEW public.datos_basicos_voluntarios_no_profesionales OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 18145)
-- Name: titulo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.titulo (
    dni integer NOT NULL,
    titulo character varying(50) NOT NULL,
    tipo_titulo character varying(20) NOT NULL
);


ALTER TABLE public.titulo OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 18148)
-- Name: datos_basicos_voluntarios_profesionales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.datos_basicos_voluntarios_profesionales AS
 SELECT d.nombre,
    d.apellido,
    d.dni,
    d.cuil,
    d.ciudad,
    d.calle,
    d.numero,
    d.depto,
    d.email,
    d.fecha_nac,
    f.telefono,
    t.tipo_titulo,
    t.titulo,
    v.id
   FROM (((public.persona d
     JOIN public.voluntario v ON ((v.dni = d.dni)))
     JOIN public.titulo t ON ((d.dni = t.dni)))
     JOIN public.telefono f ON ((f.dni = d.dni)))
  ORDER BY d.nombre, d.apellido;


ALTER VIEW public.datos_basicos_voluntarios_profesionales OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18153)
-- Name: es_pariente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.es_pariente (
    dni_familiar integer NOT NULL,
    dni_paciente integer NOT NULL,
    relacion character varying(20) NOT NULL
);


ALTER TABLE public.es_pariente OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 18156)
-- Name: no_voluntario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.no_voluntario (
    nro_afiliado integer,
    descripcion character varying(50),
    dni integer NOT NULL,
    tipo character varying(15) NOT NULL,
    nombre_cobertura_social character varying(50)
);


ALTER TABLE public.no_voluntario OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18159)
-- Name: datos_familiares; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.datos_familiares AS
 SELECT p.nombre,
    p.apellido,
    p.dni,
    p.cuil,
    p.ciudad,
    p.calle,
    p.numero,
    p.depto,
    p.email,
    p.fecha_nac,
    t.telefono,
    n.nombre_cobertura_social,
    n.nro_afiliado,
    n.descripcion,
    e.relacion,
    p2.dni AS dni_paciente
   FROM ((((public.persona p
     JOIN public.telefono t ON ((t.dni = p.dni)))
     JOIN public.no_voluntario n ON ((n.dni = p.dni)))
     JOIN public.es_pariente e ON ((e.dni_familiar = p.dni)))
     JOIN public.persona p2 ON ((p2.dni = e.dni_paciente)))
  ORDER BY p.nombre, p.apellido;


ALTER VIEW public.datos_familiares OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 18164)
-- Name: paciente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paciente (
    legajo_proceso_salud character varying(100) NOT NULL,
    legajo_socioeconomico character varying(100) NOT NULL,
    dni integer NOT NULL
);


ALTER TABLE public.paciente OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18167)
-- Name: datos_pacientes_completos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.datos_pacientes_completos AS
 SELECT p.nombre,
    p.apellido,
    p.dni,
    p.cuil,
    p.ciudad,
    p.calle,
    p.numero,
    p.depto,
    p.email,
    p.fecha_nac,
    n.nombre_cobertura_social,
    n.nro_afiliado,
    n.descripcion,
    a.legajo_proceso_salud,
    a.legajo_socioeconomico
   FROM ((public.persona p
     JOIN public.no_voluntario n ON ((p.dni = n.dni)))
     JOIN public.paciente a ON ((n.dni = a.dni)))
  ORDER BY p.nombre, p.apellido;


ALTER VIEW public.datos_pacientes_completos OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 18172)
-- Name: sede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sede (
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL,
    ciudad character varying(15) NOT NULL,
    calle character varying(20) NOT NULL,
    numero integer NOT NULL,
    horario character varying(50),
    email character varying(40) NOT NULL
);


ALTER TABLE public.sede OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18175)
-- Name: telefono_sede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telefono_sede (
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL,
    telefono character varying(20) NOT NULL
);


ALTER TABLE public.telefono_sede OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 18178)
-- Name: datos_sedes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.datos_sedes AS
 SELECT s.id_sede,
    s.id_institucion,
    s.ciudad,
    s.calle,
    s.numero,
    s.email,
    s.horario,
    t.telefono
   FROM (public.sede s
     JOIN public.telefono_sede t ON (((s.id_sede = t.id_sede) AND (s.id_institucion = t.id_institucion))))
  ORDER BY s.id_sede;


ALTER VIEW public.datos_sedes OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 18410)
-- Name: facebook_event_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facebook_event_items (
    id bigint NOT NULL,
    facebook_post_id bigint NOT NULL,
    tag character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT facebook_event_items_tag_check CHECK (((tag)::text = ANY ((ARRAY['tandil'::character varying, 'juarez'::character varying, 'next'::character varying])::text[])))
);


ALTER TABLE public.facebook_event_items OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 18409)
-- Name: facebook_event_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.facebook_event_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.facebook_event_items_id_seq OWNER TO postgres;

--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 252
-- Name: facebook_event_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.facebook_event_items_id_seq OWNED BY public.facebook_event_items.id;


--
-- TOC entry 251 (class 1259 OID 18403)
-- Name: facebook_news_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facebook_news_items (
    id bigint NOT NULL,
    facebook_post_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.facebook_news_items OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 18402)
-- Name: facebook_news_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.facebook_news_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.facebook_news_items_id_seq OWNER TO postgres;

--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 250
-- Name: facebook_news_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.facebook_news_items_id_seq OWNED BY public.facebook_news_items.id;


--
-- TOC entry 236 (class 1259 OID 18182)
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 18188)
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO postgres;

--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 237
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- TOC entry 238 (class 1259 OID 18189)
-- Name: familiar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.familiar (
    dni integer NOT NULL
);


ALTER TABLE public.familiar OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 18192)
-- Name: institucion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.institucion (
    id_institucion integer NOT NULL,
    nombre character varying(30) NOT NULL
);


ALTER TABLE public.institucion OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 18439)
-- Name: jano_por_todos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jano_por_todos (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.jano_por_todos OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 18438)
-- Name: jano_por_todos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jano_por_todos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jano_por_todos_id_seq OWNER TO postgres;

--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 258
-- Name: jano_por_todos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jano_por_todos_id_seq OWNED BY public.jano_por_todos.id;


--
-- TOC entry 240 (class 1259 OID 18195)
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 18198)
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 241
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- TOC entry 242 (class 1259 OID 18199)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 18204)
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 18209)
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 244
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- TOC entry 245 (class 1259 OID 18210)
-- Name: profesional; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profesional (
    dni integer NOT NULL
);


ALTER TABLE public.profesional OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 18427)
-- Name: professionals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.professionals (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    surname character varying(255) NOT NULL,
    birth_date date NOT NULL,
    phone character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    profession character varying(255) NOT NULL,
    training character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.professionals OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 18426)
-- Name: professionals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.professionals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.professionals_id_seq OWNER TO postgres;

--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 256
-- Name: professionals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.professionals_id_seq OWNED BY public.professionals.id;


--
-- TOC entry 246 (class 1259 OID 18213)
-- Name: servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicio (
    id_servicio integer NOT NULL,
    nombre character varying(100) NOT NULL,
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL,
    max_personas integer NOT NULL
);


ALTER TABLE public.servicio OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 18216)
-- Name: servicio_id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.servicio_id_servicio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.servicio_id_servicio_seq OWNER TO postgres;

--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 247
-- Name: servicio_id_servicio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.servicio_id_servicio_seq OWNED BY public.servicio.id_servicio;


--
-- TOC entry 248 (class 1259 OID 18217)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    rol character varying(20) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 18222)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 249
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4868 (class 2604 OID 18421)
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- TOC entry 4867 (class 2604 OID 18413)
-- Name: facebook_event_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facebook_event_items ALTER COLUMN id SET DEFAULT nextval('public.facebook_event_items_id_seq'::regclass);


--
-- TOC entry 4866 (class 2604 OID 18406)
-- Name: facebook_news_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facebook_news_items ALTER COLUMN id SET DEFAULT nextval('public.facebook_news_items_id_seq'::regclass);


--
-- TOC entry 4860 (class 2604 OID 18223)
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- TOC entry 4870 (class 2604 OID 18442)
-- Name: jano_por_todos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jano_por_todos ALTER COLUMN id SET DEFAULT nextval('public.jano_por_todos_id_seq'::regclass);


--
-- TOC entry 4862 (class 2604 OID 18224)
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- TOC entry 4863 (class 2604 OID 18225)
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- TOC entry 4869 (class 2604 OID 18430)
-- Name: professionals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals ALTER COLUMN id SET DEFAULT nextval('public.professionals_id_seq'::regclass);


--
-- TOC entry 4864 (class 2604 OID 18226)
-- Name: servicio id_servicio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio ALTER COLUMN id_servicio SET DEFAULT nextval('public.servicio_id_servicio_seq'::regclass);


--
-- TOC entry 4865 (class 2604 OID 18227)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5127 (class 0 OID 18113)
-- Dependencies: 216
-- Data for Name: atiende; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.atiende (dni_paciente, dni_profesional) FROM stdin;
48000000	40500900
49000000	40500900
47000000	40864596
\.


--
-- TOC entry 5128 (class 0 OID 18116)
-- Dependencies: 217
-- Data for Name: capacitacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.capacitacion (capacitacion, fecha, otorgado_por, dni) FROM stdin;
\.


--
-- TOC entry 5129 (class 0 OID 18119)
-- Dependencies: 218
-- Data for Name: cobertura_social; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cobertura_social (nombre) FROM stdin;
ospe
ioma
\.


--
-- TOC entry 5130 (class 0 OID 18122)
-- Dependencies: 219
-- Data for Name: colabora; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.colabora (id_servicio, dni, id_sede, id_institucion) FROM stdin;
\.


--
-- TOC entry 5161 (class 0 OID 18418)
-- Dependencies: 255
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contacts (id, "fullName", email, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5137 (class 0 OID 18153)
-- Dependencies: 228
-- Data for Name: es_pariente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.es_pariente (dni_familiar, dni_paciente, relacion) FROM stdin;
\.


--
-- TOC entry 5159 (class 0 OID 18410)
-- Dependencies: 253
-- Data for Name: facebook_event_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.facebook_event_items (id, facebook_post_id, tag, created_at, updated_at) FROM stdin;
1	644258887744689	tandil	2024-01-24 16:09:33	2024-01-24 16:09:33
2	632335558937022	tandil	2024-01-24 16:09:33	2024-01-24 16:09:33
3	2564870846986434	tandil	2024-01-24 16:09:33	2024-01-24 16:09:33
4	627728559397722	juarez	2024-01-24 16:09:33	2024-01-24 16:09:33
\.


--
-- TOC entry 5157 (class 0 OID 18403)
-- Dependencies: 251
-- Data for Name: facebook_news_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.facebook_news_items (id, facebook_post_id, created_at, updated_at) FROM stdin;
1	648217694015475	2024-01-24 16:09:33	2024-01-24 16:09:33
2	648664413970803	2024-01-24 16:09:33	2024-01-24 16:09:33
\.


--
-- TOC entry 5142 (class 0 OID 18182)
-- Dependencies: 236
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- TOC entry 5144 (class 0 OID 18189)
-- Dependencies: 238
-- Data for Name: familiar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.familiar (dni) FROM stdin;
\.


--
-- TOC entry 5145 (class 0 OID 18192)
-- Dependencies: 239
-- Data for Name: institucion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.institucion (id_institucion, nombre) FROM stdin;
1	jano
\.


--
-- TOC entry 5165 (class 0 OID 18439)
-- Dependencies: 259
-- Data for Name: jano_por_todos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jano_por_todos (id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5146 (class 0 OID 18195)
-- Dependencies: 240
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
2	2014_10_12_100000_create_password_reset_tokens_table	1
3	2019_08_19_000000_create_failed_jobs_table	1
4	2019_12_14_000001_create_personal_access_tokens_table	1
5	2023_10_24_192248_create_facebook_news_items_table	2
6	2023_10_24_192257_create_facebook_event_items_table	3
7	2023_10_25_132120_create_contacts_table	3
8	2023_10_25_201309_create_professionals_table	3
9	2024_01_24_153721_create_atiende_table	4
10	2024_01_24_153721_create_capacitacion_table	4
11	2024_01_24_153721_create_cobertura_social_table	4
12	2024_01_24_153721_create_colabora_table	4
13	2024_01_24_153721_create_contacts_table	4
14	2024_01_24_153721_create_es_pariente_table	4
15	2024_01_24_153721_create_facebook_event_items_table	4
16	2024_01_24_153721_create_facebook_news_items_table	4
17	2024_01_24_153721_create_failed_jobs_table	4
18	2024_01_24_153721_create_familiar_table	4
19	2024_01_24_153721_create_institucion_table	4
20	2024_01_24_153721_create_no_profesional_table	4
21	2024_01_24_153721_create_no_voluntario_table	4
22	2024_01_24_153721_create_oficio_table	4
23	2024_01_24_153721_create_paciente_table	4
24	2024_01_24_153721_create_password_reset_tokens_table	4
25	2024_01_24_153721_create_persona_table	4
26	2024_01_24_153721_create_personal_access_tokens_table	4
27	2024_01_24_153721_create_profesional_table	4
28	2024_01_24_153721_create_professionals_table	4
29	2024_01_24_153721_create_sede_table	4
30	2024_01_24_153721_create_servicio_table	4
31	2024_01_24_153721_create_telefono_table	4
32	2024_01_24_153721_create_telefono_sede_table	4
33	2024_01_24_153721_create_titulo_table	4
34	2024_01_24_153721_create_users_table	4
35	2024_01_24_153721_create_voluntario_table	4
36	2024_01_24_153722_create_datos_pacientes_completos_view	4
37	2024_01_24_153722_create_datos_basicos_voluntarios_no_profesionales_view	4
38	2024_01_24_153722_create_datos_basicos_voluntarios_profesionales_view	4
39	2024_01_24_153722_create_datos_familiares_view	4
40	2024_01_24_153722_create_datos_sedes_view	4
41	2024_01_24_153724_add_foreign_keys_to_atiende_table	4
42	2024_01_24_153724_add_foreign_keys_to_capacitacion_table	4
43	2024_01_24_153724_add_foreign_keys_to_colabora_table	4
44	2024_01_24_153724_add_foreign_keys_to_es_pariente_table	4
45	2024_01_24_153724_add_foreign_keys_to_familiar_table	4
46	2024_01_24_153724_add_foreign_keys_to_no_voluntario_table	4
47	2024_01_24_153724_add_foreign_keys_to_oficio_table	4
48	2024_01_24_153724_add_foreign_keys_to_paciente_table	4
49	2024_01_24_153724_add_foreign_keys_to_profesional_table	4
50	2024_01_24_153724_add_foreign_keys_to_sede_table	4
51	2024_01_24_153724_add_foreign_keys_to_servicio_table	4
52	2024_01_24_153724_add_foreign_keys_to_telefono_table	4
53	2024_01_24_153724_add_foreign_keys_to_telefono_sede_table	4
54	2024_01_24_153724_add_foreign_keys_to_titulo_table	4
55	2024_01_24_153724_add_foreign_keys_to_voluntario_table	4
1	2014_10_12_000000_create_users_table	1
56	2023_11_24_001148_create_jano_por_todos_table	5
\.


--
-- TOC entry 5131 (class 0 OID 18125)
-- Dependencies: 220
-- Data for Name: no_profesional; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.no_profesional (area_desarrollo, dni) FROM stdin;
\.


--
-- TOC entry 5138 (class 0 OID 18156)
-- Dependencies: 229
-- Data for Name: no_voluntario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.no_voluntario (nro_afiliado, descripcion, dni, tipo, nombre_cobertura_social) FROM stdin;
\N	\N	48000000	P	\N
\N	\N	49000000	P	\N
\N	\N	45565656	P	\N
\N	\N	47000000	P	\N
\.


--
-- TOC entry 5132 (class 0 OID 18128)
-- Dependencies: 221
-- Data for Name: oficio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oficio (oficio, dni) FROM stdin;
\.


--
-- TOC entry 5139 (class 0 OID 18164)
-- Dependencies: 231
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paciente (legajo_proceso_salud, legajo_socioeconomico, dni) FROM stdin;
Legajo1	Legajo2	48000000
legajo3	legajo4	49000000
legajo3	legajo4	45565656
leg1	leg3	47000000
\.


--
-- TOC entry 5148 (class 0 OID 18199)
-- Dependencies: 242
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- TOC entry 5133 (class 0 OID 18131)
-- Dependencies: 222
-- Data for Name: persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.persona (dni, cuil, nombre, apellido, ciudad, calle, numero, depto, email, fecha_nac, rol) FROM stdin;
40500900	27405009000	Lucia	Gomez	Tandil	Av. España	50	\N	lucia@gmail.com	1998-01-01	V
48000000	48000000	Julieta	Perez	Tandil	Belgrano	100	\N	julieta@gmail.com	2008-01-01	N
49000000	49000000	Julieta	Perez2	Tandil	Belgrano	200	\N	julietap@gmail.com	2007-01-01	N
41200300	20412003005	Juan	perez	Tandil	Alsina	450	\N	juanp@gmail.com	1978-01-15	V
40864596	20408645965	Geronimo	Pose	tandil	ppp	222	\N	pose.gero@gmail.com	1998-02-12	V
45565656	20455656565	carlitos	carlos	tandil	usp	450	\N	ppp@gmail.com	2000-12-12	N
47000000	20470000002	pedro	pedr	tandil	usp	450	\N	ppp1234@gmail.com	1998-12-12	N
\.


--
-- TOC entry 5149 (class 0 OID 18204)
-- Dependencies: 243
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5151 (class 0 OID 18210)
-- Dependencies: 245
-- Data for Name: profesional; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profesional (dni) FROM stdin;
40500900
41200300
40864596
\.


--
-- TOC entry 5163 (class 0 OID 18427)
-- Dependencies: 257
-- Data for Name: professionals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professionals (id, name, surname, birth_date, phone, city, email, profession, training, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5140 (class 0 OID 18172)
-- Dependencies: 233
-- Data for Name: sede; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sede (id_sede, id_institucion, ciudad, calle, numero, horario, email) FROM stdin;
1	1	tandil	roca	455	17	jano@gmail.com
\.


--
-- TOC entry 5152 (class 0 OID 18213)
-- Dependencies: 246
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.servicio (id_servicio, nombre, id_sede, id_institucion, max_personas) FROM stdin;
7	Comedor	1	1	10
\.


--
-- TOC entry 5134 (class 0 OID 18134)
-- Dependencies: 223
-- Data for Name: telefono; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.telefono (dni, telefono) FROM stdin;
40500900	2494111111
41200300	2494556566
\.


--
-- TOC entry 5141 (class 0 OID 18175)
-- Dependencies: 234
-- Data for Name: telefono_sede; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.telefono_sede (id_sede, id_institucion, telefono) FROM stdin;
1	1	2494526232
\.


--
-- TOC entry 5136 (class 0 OID 18145)
-- Dependencies: 226
-- Data for Name: titulo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.titulo (dni, titulo, tipo_titulo) FROM stdin;
40500900	Licenciatura en psicologia	Universitario
41200300	Psicologo	Profesional
\.


--
-- TOC entry 5154 (class 0 OID 18217)
-- Dependencies: 248
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, rol) FROM stdin;
6	Amaike Gopar	amaikegopar60@gmail.com	\N	$2y$12$mPeY57bvwmEXqpTXmIqoDu7dclFna9y1wzzhh5untLocC0qs552py	\N	2023-12-09 14:11:28	2023-12-09 14:11:28	admin
12	Jano por todos	janoportodos@gmail.com	\N	$2y$12$kbi889GiFQk3RPqg.6/oi.cv5UBR6JAzlijSFrbm05vnu1hSI4zna	\N	2023-12-13 11:51:42	2023-12-13 11:51:42	admin
14	Lucia	lucia@gmail.com	\N	$2y$12$MmYD0kuiGcTAuqw0WTF42e9d4soIKHL9zQkRg2xqCh66KuBt2f6WC	\N	2023-12-13 12:09:34	2023-12-13 12:09:34	profesional
17	Juan	juanp@gmail.com	\N	$2y$12$RFB7vG83XKFPMUaE3xtbVuS4GYfCJI4YZVn/bOwfnkVrDadkgo5Le	\N	2024-02-11 18:12:14	2024-02-11 18:12:14	profesional
15	Gero	pose.gero@gmail.com	\N	$2y$12$u2UbHc.U8J7CMdM93KkRsuhb3.SmS9z0NbTy9PQz3Jx1SuDcKPXzO	v39HJ6UqQjKwMdb1GSFefnhoNTgFVzy1DY5BKW6f0jMOKia4wAkkgTKTkw8T	2024-01-03 15:39:13	2024-01-03 15:39:13	admin
\.


--
-- TOC entry 5135 (class 0 OID 18137)
-- Dependencies: 224
-- Data for Name: voluntario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voluntario (tipo, dni, remember_token, id) FROM stdin;
P	40500900	\N	14
P	41200300	\N	17
P	40864596		15
\.


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 254
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contacts_id_seq', 1, false);


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 252
-- Name: facebook_event_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.facebook_event_items_id_seq', 4, true);


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 250
-- Name: facebook_news_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.facebook_news_items_id_seq', 2, true);


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 237
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 258
-- Name: jano_por_todos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jano_por_todos_id_seq', 1, false);


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 241
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 56, true);


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 244
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 256
-- Name: professionals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.professionals_id_seq', 1, false);


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 247
-- Name: servicio_id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.servicio_id_servicio_seq', 7, true);


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 249
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 35, true);


--
-- TOC entry 4938 (class 2606 OID 18425)
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- TOC entry 4936 (class 2606 OID 18416)
-- Name: facebook_event_items facebook_event_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facebook_event_items
    ADD CONSTRAINT facebook_event_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4934 (class 2606 OID 18408)
-- Name: facebook_news_items facebook_news_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facebook_news_items
    ADD CONSTRAINT facebook_news_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4905 (class 2606 OID 18229)
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 4907 (class 2606 OID 18231)
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- TOC entry 4942 (class 2606 OID 18444)
-- Name: jano_por_todos jano_por_todos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jano_por_todos
    ADD CONSTRAINT jano_por_todos_pkey PRIMARY KEY (id);


--
-- TOC entry 4915 (class 2606 OID 18233)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 4917 (class 2606 OID 18235)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- TOC entry 4919 (class 2606 OID 18237)
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4921 (class 2606 OID 18239)
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- TOC entry 4877 (class 2606 OID 18241)
-- Name: cobertura_social pk_cobertura_social; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cobertura_social
    ADD CONSTRAINT pk_cobertura_social PRIMARY KEY (nombre);


--
-- TOC entry 4885 (class 2606 OID 18243)
-- Name: persona pk_dni; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT pk_dni PRIMARY KEY (dni);


--
-- TOC entry 4873 (class 2606 OID 18245)
-- Name: atiende pk_dni_atiende; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atiende
    ADD CONSTRAINT pk_dni_atiende PRIMARY KEY (dni_paciente, dni_profesional);


--
-- TOC entry 4875 (class 2606 OID 18247)
-- Name: capacitacion pk_dni_capacitacion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capacitacion
    ADD CONSTRAINT pk_dni_capacitacion PRIMARY KEY (dni, capacitacion);


--
-- TOC entry 4909 (class 2606 OID 18249)
-- Name: familiar pk_dni_familiar; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.familiar
    ADD CONSTRAINT pk_dni_familiar PRIMARY KEY (dni);


--
-- TOC entry 4881 (class 2606 OID 18251)
-- Name: no_profesional pk_dni_no_profesional; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.no_profesional
    ADD CONSTRAINT pk_dni_no_profesional PRIMARY KEY (dni);


--
-- TOC entry 4897 (class 2606 OID 18253)
-- Name: no_voluntario pk_dni_no_voluntario; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.no_voluntario
    ADD CONSTRAINT pk_dni_no_voluntario PRIMARY KEY (dni);


--
-- TOC entry 4883 (class 2606 OID 18255)
-- Name: oficio pk_dni_oficio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oficio
    ADD CONSTRAINT pk_dni_oficio PRIMARY KEY (dni, oficio);


--
-- TOC entry 4899 (class 2606 OID 18257)
-- Name: paciente pk_dni_paciente; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT pk_dni_paciente PRIMARY KEY (dni);


--
-- TOC entry 4895 (class 2606 OID 18259)
-- Name: es_pariente pk_dni_pariente; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.es_pariente
    ADD CONSTRAINT pk_dni_pariente PRIMARY KEY (dni_familiar, dni_paciente);


--
-- TOC entry 4879 (class 2606 OID 18261)
-- Name: colabora pk_dni_servicio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.colabora
    ADD CONSTRAINT pk_dni_servicio PRIMARY KEY (dni, id_servicio, id_sede, id_institucion);


--
-- TOC entry 4893 (class 2606 OID 18263)
-- Name: titulo pk_dni_titulo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.titulo
    ADD CONSTRAINT pk_dni_titulo PRIMARY KEY (dni, titulo);


--
-- TOC entry 4891 (class 2606 OID 18265)
-- Name: voluntario pk_dni_voluntario; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voluntario
    ADD CONSTRAINT pk_dni_voluntario PRIMARY KEY (dni);


--
-- TOC entry 4924 (class 2606 OID 18267)
-- Name: profesional pk_dniprof; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesional
    ADD CONSTRAINT pk_dniprof PRIMARY KEY (dni);


--
-- TOC entry 4911 (class 2606 OID 18269)
-- Name: institucion pk_id_institucion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT pk_id_institucion PRIMARY KEY (id_institucion);


--
-- TOC entry 4901 (class 2606 OID 18271)
-- Name: sede pk_sede; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sede
    ADD CONSTRAINT pk_sede PRIMARY KEY (id_sede, id_institucion);


--
-- TOC entry 4926 (class 2606 OID 18273)
-- Name: servicio pk_servicio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT pk_servicio PRIMARY KEY (id_servicio, id_sede, id_institucion);


--
-- TOC entry 4889 (class 2606 OID 18275)
-- Name: telefono pk_telefono; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telefono
    ADD CONSTRAINT pk_telefono PRIMARY KEY (dni, telefono);


--
-- TOC entry 4903 (class 2606 OID 18277)
-- Name: telefono_sede pk_telefono_sede; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telefono_sede
    ADD CONSTRAINT pk_telefono_sede PRIMARY KEY (id_sede, id_institucion, telefono);


--
-- TOC entry 4940 (class 2606 OID 18434)
-- Name: professionals professionals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_pkey PRIMARY KEY (id);


--
-- TOC entry 4887 (class 2606 OID 18279)
-- Name: persona uq_cuil; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT uq_cuil UNIQUE (cuil);


--
-- TOC entry 4913 (class 2606 OID 18281)
-- Name: institucion uq_nombre_institucion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT uq_nombre_institucion UNIQUE (nombre);


--
-- TOC entry 4928 (class 2606 OID 18283)
-- Name: servicio uq_nombre_serv; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT uq_nombre_serv UNIQUE (nombre);


--
-- TOC entry 4930 (class 2606 OID 18285)
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- TOC entry 4932 (class 2606 OID 18287)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4922 (class 1259 OID 18288)
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- TOC entry 4962 (class 2620 OID 18289)
-- Name: colabora check_max_personas_colabora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_max_personas_colabora BEFORE INSERT OR UPDATE OF id_servicio, id_sede, id_institucion ON public.colabora FOR EACH ROW EXECUTE FUNCTION public.max_voluntarios_colabora();


--
-- TOC entry 4978 (class 2620 OID 18290)
-- Name: servicio check_max_personas_servicio; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_max_personas_servicio BEFORE UPDATE OF max_personas ON public.servicio FOR EACH ROW EXECUTE FUNCTION public.max_voluntarios_servicio();


--
-- TOC entry 4965 (class 2620 OID 18291)
-- Name: persona ck_cambio_ciudad; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_cambio_ciudad BEFORE UPDATE OF ciudad ON public.persona FOR EACH ROW EXECUTE FUNCTION public.cambio_ciudad();


--
-- TOC entry 4974 (class 2620 OID 18292)
-- Name: sede ck_cambio_ciudad_sede; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_cambio_ciudad_sede BEFORE UPDATE OF ciudad ON public.sede FOR EACH ROW EXECUTE FUNCTION public.cambio_ciudad_sede();


--
-- TOC entry 4963 (class 2620 OID 18293)
-- Name: colabora ck_insert_colabora; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_colabora AFTER INSERT OR UPDATE OF id_sede, id_institucion ON public.colabora FOR EACH ROW EXECUTE FUNCTION public.insert_colabora();


--
-- TOC entry 4976 (class 2620 OID 18294)
-- Name: familiar ck_insert_familiar; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_familiar BEFORE INSERT OR UPDATE OF dni ON public.familiar FOR EACH ROW EXECUTE FUNCTION public.insert_familiar();


--
-- TOC entry 4964 (class 2620 OID 18295)
-- Name: no_profesional ck_insert_no_profesional; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_no_profesional BEFORE INSERT OR UPDATE OF dni ON public.no_profesional FOR EACH ROW EXECUTE FUNCTION public.insert_no_profesional();


--
-- TOC entry 4970 (class 2620 OID 18296)
-- Name: no_voluntario ck_insert_no_voluntario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_no_voluntario BEFORE INSERT OR UPDATE OF dni ON public.no_voluntario FOR EACH ROW EXECUTE FUNCTION public.insert_no_voluntario();


--
-- TOC entry 4966 (class 2620 OID 18297)
-- Name: voluntario ck_insert_no_voluntario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_no_voluntario BEFORE INSERT OR UPDATE OF dni ON public.voluntario FOR EACH ROW EXECUTE FUNCTION public.insert_no_voluntario();


--
-- TOC entry 4972 (class 2620 OID 18298)
-- Name: paciente ck_insert_paciente; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_paciente BEFORE INSERT OR UPDATE OF dni ON public.paciente FOR EACH ROW EXECUTE FUNCTION public.insert_paciente();


--
-- TOC entry 4977 (class 2620 OID 18299)
-- Name: profesional ck_insert_profesional; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_profesional BEFORE INSERT OR UPDATE OF dni ON public.profesional FOR EACH ROW EXECUTE FUNCTION public.insert_profesional();


--
-- TOC entry 4967 (class 2620 OID 18300)
-- Name: voluntario ck_insert_voluntario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ck_insert_voluntario BEFORE INSERT OR UPDATE OF dni ON public.voluntario FOR EACH ROW EXECUTE FUNCTION public.insert_voluntario();


--
-- TOC entry 4971 (class 2620 OID 18301)
-- Name: datos_familiares tg_actualizar_datos_familiares; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_actualizar_datos_familiares INSTEAD OF INSERT OR DELETE OR UPDATE ON public.datos_familiares FOR EACH ROW EXECUTE FUNCTION public.actualizar_datos_familiares();


--
-- TOC entry 4975 (class 2620 OID 18302)
-- Name: datos_sedes tg_actualizar_datos_sede; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_actualizar_datos_sede INSTEAD OF INSERT OR DELETE OR UPDATE ON public.datos_sedes FOR EACH ROW EXECUTE FUNCTION public.actualizar_datos_sede();


--
-- TOC entry 4968 (class 2620 OID 18303)
-- Name: datos_basicos_voluntarios_no_profesionales tg_actualizar_datos_voluntarios_no_profesionales; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_actualizar_datos_voluntarios_no_profesionales INSTEAD OF INSERT OR DELETE OR UPDATE ON public.datos_basicos_voluntarios_no_profesionales FOR EACH ROW EXECUTE FUNCTION public.actualizar_datos_voluntarios_no_profesionales();


--
-- TOC entry 4969 (class 2620 OID 18304)
-- Name: datos_basicos_voluntarios_profesionales tg_actualizar_datos_voluntarios_profesionales; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_actualizar_datos_voluntarios_profesionales INSTEAD OF INSERT OR DELETE OR UPDATE ON public.datos_basicos_voluntarios_profesionales FOR EACH ROW EXECUTE FUNCTION public.actualizar_datos_voluntarios_profesionales();


--
-- TOC entry 4973 (class 2620 OID 18305)
-- Name: datos_pacientes_completos tg_datos_pacientes_completos; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_datos_pacientes_completos INSTEAD OF INSERT OR DELETE OR UPDATE ON public.datos_pacientes_completos FOR EACH ROW EXECUTE FUNCTION public.actualizar_datos_pacientes();


--
-- TOC entry 4945 (class 2606 OID 18306)
-- Name: capacitacion fk_dni_capacitacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capacitacion
    ADD CONSTRAINT fk_dni_capacitacion FOREIGN KEY (dni) REFERENCES public.no_profesional(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4946 (class 2606 OID 18311)
-- Name: colabora fk_dni_colabora; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.colabora
    ADD CONSTRAINT fk_dni_colabora FOREIGN KEY (dni) REFERENCES public.voluntario(dni) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4959 (class 2606 OID 18316)
-- Name: familiar fk_dni_familiar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.familiar
    ADD CONSTRAINT fk_dni_familiar FOREIGN KEY (dni) REFERENCES public.no_voluntario(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4952 (class 2606 OID 18321)
-- Name: es_pariente fk_dni_familiar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.es_pariente
    ADD CONSTRAINT fk_dni_familiar FOREIGN KEY (dni_familiar) REFERENCES public.familiar(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4954 (class 2606 OID 18326)
-- Name: no_voluntario fk_dni_no_voluntario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.no_voluntario
    ADD CONSTRAINT fk_dni_no_voluntario FOREIGN KEY (dni) REFERENCES public.persona(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4948 (class 2606 OID 18331)
-- Name: oficio fk_dni_oficio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oficio
    ADD CONSTRAINT fk_dni_oficio FOREIGN KEY (dni) REFERENCES public.no_profesional(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4956 (class 2606 OID 18336)
-- Name: paciente fk_dni_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT fk_dni_paciente FOREIGN KEY (dni) REFERENCES public.no_voluntario(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4943 (class 2606 OID 18341)
-- Name: atiende fk_dni_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atiende
    ADD CONSTRAINT fk_dni_paciente FOREIGN KEY (dni_paciente) REFERENCES public.paciente(dni) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4953 (class 2606 OID 18346)
-- Name: es_pariente fk_dni_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.es_pariente
    ADD CONSTRAINT fk_dni_paciente FOREIGN KEY (dni_paciente) REFERENCES public.paciente(dni) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4960 (class 2606 OID 18351)
-- Name: profesional fk_dni_profesional; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesional
    ADD CONSTRAINT fk_dni_profesional FOREIGN KEY (dni) REFERENCES public.voluntario(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4944 (class 2606 OID 18356)
-- Name: atiende fk_dni_profesional; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atiende
    ADD CONSTRAINT fk_dni_profesional FOREIGN KEY (dni_profesional) REFERENCES public.profesional(dni) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4949 (class 2606 OID 18361)
-- Name: telefono fk_dni_telefono; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telefono
    ADD CONSTRAINT fk_dni_telefono FOREIGN KEY (dni) REFERENCES public.persona(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4951 (class 2606 OID 18366)
-- Name: titulo fk_dni_titulo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.titulo
    ADD CONSTRAINT fk_dni_titulo FOREIGN KEY (dni) REFERENCES public.profesional(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4950 (class 2606 OID 18371)
-- Name: voluntario fk_dni_voluntario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voluntario
    ADD CONSTRAINT fk_dni_voluntario FOREIGN KEY (dni) REFERENCES public.persona(dni) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4957 (class 2606 OID 18376)
-- Name: sede fk_id_institucion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sede
    ADD CONSTRAINT fk_id_institucion FOREIGN KEY (id_institucion) REFERENCES public.institucion(id_institucion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4955 (class 2606 OID 18381)
-- Name: no_voluntario fk_no_voluntario_cobertura_social; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.no_voluntario
    ADD CONSTRAINT fk_no_voluntario_cobertura_social FOREIGN KEY (nombre_cobertura_social) REFERENCES public.cobertura_social(nombre);


--
-- TOC entry 4961 (class 2606 OID 18386)
-- Name: servicio fk_servicio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT fk_servicio FOREIGN KEY (id_sede, id_institucion) REFERENCES public.sede(id_sede, id_institucion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4947 (class 2606 OID 18391)
-- Name: colabora fk_servicio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.colabora
    ADD CONSTRAINT fk_servicio FOREIGN KEY (id_servicio, id_sede, id_institucion) REFERENCES public.servicio(id_servicio, id_sede, id_institucion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4958 (class 2606 OID 18396)
-- Name: telefono_sede fk_telefono_sede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telefono_sede
    ADD CONSTRAINT fk_telefono_sede FOREIGN KEY (id_sede, id_institucion) REFERENCES public.sede(id_sede, id_institucion) ON UPDATE RESTRICT ON DELETE CASCADE;


-- Completed on 2024-02-23 09:35:44

--
-- PostgreSQL database dump complete
--

