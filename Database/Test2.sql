PGDMP      7                |            PPS    16.1    16.1 �               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                        0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            !           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            "           1262    27834    PPS    DATABASE     |   CREATE DATABASE "PPS" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Argentina.1252';
    DROP DATABASE "PPS";
                postgres    false                        3079    27835    unaccent 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;
    DROP EXTENSION unaccent;
                   false            #           0    0    EXTENSION unaccent    COMMENT     P   COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';
                        false    2                       1255    27842    actualizar_datos_familiares()    FUNCTION     

  CREATE FUNCTION public.actualizar_datos_familiares() RETURNS trigger
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
 4   DROP FUNCTION public.actualizar_datos_familiares();
       public          postgres    false                        1255    27843    actualizar_datos_pacientes()    FUNCTION     �	  CREATE FUNCTION public.actualizar_datos_pacientes() RETURNS trigger
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
 3   DROP FUNCTION public.actualizar_datos_pacientes();
       public          postgres    false            !           1255    27844    actualizar_datos_sede()    FUNCTION       CREATE FUNCTION public.actualizar_datos_sede() RETURNS trigger
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
 .   DROP FUNCTION public.actualizar_datos_sede();
       public          postgres    false            "           1255    27845    actualizar_datos_voluntarios()    FUNCTION     �  CREATE FUNCTION public.actualizar_datos_voluntarios() RETURNS trigger
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
 5   DROP FUNCTION public.actualizar_datos_voluntarios();
       public          postgres    false            #           1255    27846 /   actualizar_datos_voluntarios_no_profesionales()    FUNCTION     �  CREATE FUNCTION public.actualizar_datos_voluntarios_no_profesionales() RETURNS trigger
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
 F   DROP FUNCTION public.actualizar_datos_voluntarios_no_profesionales();
       public          postgres    false            %           1255    27847 ,   actualizar_datos_voluntarios_profesionales()    FUNCTION     �  CREATE FUNCTION public.actualizar_datos_voluntarios_profesionales() RETURNS trigger
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
 C   DROP FUNCTION public.actualizar_datos_voluntarios_profesionales();
       public          postgres    false            &           1255    27848 9   buscar_atendido_por(character varying, character varying)    FUNCTION       CREATE FUNCTION public.buscar_atendido_por(nombre_profesional character varying, apellido_profesional character varying) RETURNS TABLE(nombre_paciente character varying, apellido_paciente character varying, dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, relacion character varying, telefono character varying, cobertura_social character varying, nro_afiliado integer, legajo_proceso_salud character varying, legajo_socioeconomico character varying)
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
 x   DROP FUNCTION public.buscar_atendido_por(nombre_profesional character varying, apellido_profesional character varying);
       public          postgres    false            '           1255    27849 6   buscar_atiende_a(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.buscar_atiende_a(nombre_paciente character varying, apellido_paciente character varying) RETURNS TABLE(dni_paciente bigint, nombre_profesional character varying, apellido_profesional character varying, dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, tipo_titulo character varying, titulo character varying)
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
 o   DROP FUNCTION public.buscar_atiende_a(nombre_paciente character varying, apellido_paciente character varying);
       public          postgres    false            (           1255    27850 7   buscar_familiares(character varying, character varying)    FUNCTION     H  CREATE FUNCTION public.buscar_familiares(nombre_paciente character varying, apellido_paciente character varying) RETURNS TABLE(dni_paciente bigint, relacion character varying, nombre character varying, apellido character varying, dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, cobertura_social character varying, nro_afiliado integer, descripcion character varying)
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
 p   DROP FUNCTION public.buscar_familiares(nombre_paciente character varying, apellido_paciente character varying);
       public          postgres    false            )           1255    27851 5   buscar_paciente(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.buscar_paciente(var_nombre character varying, var_apellido character varying) RETURNS TABLE(dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, legajo_proceso_salud character varying, legajo_socieconomico character varying, cobertura_social character varying, nro_afiliado integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, p.cuil, p.ciudad, p.calle, p.numero, p.depto, p.email, p.fecha_nac, t.telefono, a.legajo_socioeconomico, a.legajo_proceso_salud ,v.nombre_cobertura_social, v.nro_afiliado, v.descripcion
	FROM persona p left join telefono t on (p.dni = t.dni) join no_voluntario v on (v.dni = p.dni) join paciente a on (a.dni = p.dni)
	where LOWER(unaccent(var_nombre)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(var_apellido)) = LOWER(unaccent(p.apellido));
END;
$$;
 d   DROP FUNCTION public.buscar_paciente(var_nombre character varying, var_apellido character varying);
       public          postgres    false            *           1255    27852 B   buscar_participa_en_servicio(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.buscar_participa_en_servicio(nombre character varying, apellido character varying) RETURNS TABLE(dni_voluntario bigint, nombre_servicio character varying, id_sede integer, ciudad character varying, calle character varying, numero integer, telefono character varying, horario character varying, email character varying)
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
 i   DROP FUNCTION public.buscar_participa_en_servicio(nombre character varying, apellido character varying);
       public          postgres    false            	           1255    27853 F   buscar_voluntario_no_profesional(character varying, character varying)    FUNCTION     }  CREATE FUNCTION public.buscar_voluntario_no_profesional(var_nombre character varying, var_apellido character varying) RETURNS TABLE(dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, oficio character varying, capacitacion character varying, fecha date, otorgado_por character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, p.cuil, p.ciudad, p.calle, p.numero, p.depto, p.email, p.fecha_nac, t.telefono, o.oficio, c.capacitacion, c.fecha, c.otorgado_por
	FROM persona p left join telefono t on (p.dni = t.dni) left join oficio o on (o.dni = p.dni) left join capacitacion c on (c.dni = p.dni)
	where LOWER(unaccent(var_nombre)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(var_apellido)) = LOWER(unaccent(p.apellido));
END;
$$;
 u   DROP FUNCTION public.buscar_voluntario_no_profesional(var_nombre character varying, var_apellido character varying);
       public          postgres    false            
           1255    27854 C   buscar_voluntario_profesional(character varying, character varying)    FUNCTION       CREATE FUNCTION public.buscar_voluntario_profesional(var_nombre character varying, var_apellido character varying) RETURNS TABLE(dni bigint, cuil bigint, ciudad character varying, calle character varying, numero integer, depto character varying, email character varying, fecha_nac date, telefono character varying, tipo_titulo character varying, titulo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.dni, p.cuil, p.ciudad, p.calle, p.numero, p.depto, p.email, p.fecha_nac, t.telefono, i.tipo_titulo, i.titulo
	FROM persona p left join telefono t on (p.dni = t.dni) left join titulo i on (i.dni = p.dni)
	where LOWER(unaccent(var_nombre)) = LOWER(unaccent(p.nombre)) and LOWER(unaccent(var_apellido)) = LOWER(unaccent(p.apellido));
END;
$$;
 r   DROP FUNCTION public.buscar_voluntario_profesional(var_nombre character varying, var_apellido character varying);
       public          postgres    false                       1255    27855    cambio_ciudad()    FUNCTION     �  CREATE FUNCTION public.cambio_ciudad() RETURNS trigger
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
 &   DROP FUNCTION public.cambio_ciudad();
       public          postgres    false                       1255    27856    cambio_ciudad_sede()    FUNCTION     �  CREATE FUNCTION public.cambio_ciudad_sede() RETURNS trigger
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
 +   DROP FUNCTION public.cambio_ciudad_sede();
       public          postgres    false                       1255    27857    insert_colabora()    FUNCTION     7  CREATE FUNCTION public.insert_colabora() RETURNS trigger
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
 (   DROP FUNCTION public.insert_colabora();
       public          postgres    false                       1255    27858    insert_familiar()    FUNCTION       CREATE FUNCTION public.insert_familiar() RETURNS trigger
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
 (   DROP FUNCTION public.insert_familiar();
       public          postgres    false                       1255    27859    insert_no_profesional()    FUNCTION     ,  CREATE FUNCTION public.insert_no_profesional() RETURNS trigger
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
 .   DROP FUNCTION public.insert_no_profesional();
       public          postgres    false                       1255    27860    insert_no_voluntario()    FUNCTION       CREATE FUNCTION public.insert_no_voluntario() RETURNS trigger
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
 -   DROP FUNCTION public.insert_no_voluntario();
       public          postgres    false                       1255    27861    insert_paciente()    FUNCTION       CREATE FUNCTION public.insert_paciente() RETURNS trigger
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
 (   DROP FUNCTION public.insert_paciente();
       public          postgres    false                       1255    27862    insert_profesional()    FUNCTION     /  CREATE FUNCTION public.insert_profesional() RETURNS trigger
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
 +   DROP FUNCTION public.insert_profesional();
       public          postgres    false                       1255    27863    insert_voluntario()    FUNCTION     9  CREATE FUNCTION public.insert_voluntario() RETURNS trigger
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
 *   DROP FUNCTION public.insert_voluntario();
       public          postgres    false                       1255    27864    max_voluntarios_colabora()    FUNCTION     e  CREATE FUNCTION public.max_voluntarios_colabora() RETURNS trigger
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
 1   DROP FUNCTION public.max_voluntarios_colabora();
       public          postgres    false            $           1255    27865    max_voluntarios_servicio()    FUNCTION       CREATE FUNCTION public.max_voluntarios_servicio() RETURNS trigger
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
 1   DROP FUNCTION public.max_voluntarios_servicio();
       public          postgres    false            �            1259    31052    atiende    TABLE     g   CREATE TABLE public.atiende (
    dni_paciente bigint NOT NULL,
    dni_profesional bigint NOT NULL
);
    DROP TABLE public.atiende;
       public         heap    postgres    false            �            1259    31057    capacitacion    TABLE     �   CREATE TABLE public.capacitacion (
    capacitacion character varying(100) NOT NULL,
    fecha timestamp(0) without time zone,
    otorgado_por character varying(50),
    dni integer NOT NULL
);
     DROP TABLE public.capacitacion;
       public         heap    postgres    false            �            1259    31062    cobertura_social    TABLE     T   CREATE TABLE public.cobertura_social (
    nombre character varying(50) NOT NULL
);
 $   DROP TABLE public.cobertura_social;
       public         heap    postgres    false            �            1259    31067    colabora    TABLE     �   CREATE TABLE public.colabora (
    id_servicio bigint NOT NULL,
    dni bigint NOT NULL,
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL
);
    DROP TABLE public.colabora;
       public         heap    postgres    false            �            1259    31073    contacts    TABLE     �   CREATE TABLE public.contacts (
    id bigint NOT NULL,
    "fullName" character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
    DROP TABLE public.contacts;
       public         heap    postgres    false            �            1259    31072    contacts_id_seq    SEQUENCE     x   CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.contacts_id_seq;
       public          postgres    false    229            $           0    0    contacts_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;
          public          postgres    false    228            �            1259    31125    no_profesional    TABLE     u   CREATE TABLE public.no_profesional (
    area_desarrollo character varying(20) NOT NULL,
    dni integer NOT NULL
);
 "   DROP TABLE public.no_profesional;
       public         heap    postgres    false            �            1259    31135    oficio    TABLE     d   CREATE TABLE public.oficio (
    oficio character varying(20) NOT NULL,
    dni integer NOT NULL
);
    DROP TABLE public.oficio;
       public         heap    postgres    false            �            1259    31152    persona    TABLE     �  CREATE TABLE public.persona (
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
    DROP TABLE public.persona;
       public         heap    postgres    false            �            1259    31192    telefono    TABLE     g   CREATE TABLE public.telefono (
    dni bigint NOT NULL,
    telefono character varying(20) NOT NULL
);
    DROP TABLE public.telefono;
       public         heap    postgres    false            �            1259    31202 
   voluntario    TABLE     �   CREATE TABLE public.voluntario (
    tipo character varying(1) NOT NULL,
    dni bigint NOT NULL,
    remember_token character varying(100),
    id bigint
);
    DROP TABLE public.voluntario;
       public         heap    postgres    false            �            1259    31207 *   datos_basicos_voluntarios_no_profesionales    VIEW     �  CREATE VIEW public.datos_basicos_voluntarios_no_profesionales AS
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
    n.area_desarrollo,
    o.oficio,
    c.capacitacion,
    c.fecha,
    c.otorgado_por,
    v.id AS voluntario_id
   FROM (((((public.persona p
     JOIN public.telefono t ON ((t.dni = p.dni)))
     JOIN public.no_profesional n ON ((n.dni = p.dni)))
     JOIN public.voluntario v ON ((v.dni = p.dni)))
     LEFT JOIN public.oficio o ON ((v.dni = o.dni)))
     LEFT JOIN public.capacitacion c ON ((v.dni = c.dni)))
  ORDER BY p.nombre, p.apellido;
 =   DROP VIEW public.datos_basicos_voluntarios_no_profesionales;
       public          postgres    false    244    241    241    239    239    244    225    225    225    225    244    244    244    252    254    254    244    244    252    244    244    244            �            1259    31159    profesional    TABLE     =   CREATE TABLE public.profesional (
    dni bigint NOT NULL
);
    DROP TABLE public.profesional;
       public         heap    postgres    false            �            1259    31197    titulo    TABLE     �   CREATE TABLE public.titulo (
    dni bigint NOT NULL,
    titulo character varying(50) NOT NULL,
    tipo_titulo character varying(20) NOT NULL
);
    DROP TABLE public.titulo;
       public         heap    postgres    false                        1259    31212 '   datos_basicos_voluntarios_profesionales    VIEW     )  CREATE VIEW public.datos_basicos_voluntarios_profesionales AS
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
    ti.tipo_titulo,
    ti.titulo,
    v.id AS voluntario_id
   FROM ((((public.persona p
     JOIN public.telefono t ON ((t.dni = p.dni)))
     JOIN public.profesional vp ON ((vp.dni = p.dni)))
     JOIN public.voluntario v ON ((v.dni = p.dni)))
     LEFT JOIN public.titulo ti ON ((v.dni = t.dni)))
  ORDER BY p.nombre, p.apellido;
 :   DROP VIEW public.datos_basicos_voluntarios_profesionales;
       public          postgres    false    244    254    254    253    253    252    252    245    244    244    244    244    244    244    244    244    244            �            1259    31081    es_pariente    TABLE     �   CREATE TABLE public.es_pariente (
    dni_familiar bigint NOT NULL,
    dni_paciente bigint NOT NULL,
    relacion character varying(20) NOT NULL
);
    DROP TABLE public.es_pariente;
       public         heap    postgres    false            �            1259    31130    no_voluntario    TABLE     �   CREATE TABLE public.no_voluntario (
    nro_afiliado integer,
    descripcion character varying(50),
    dni bigint NOT NULL,
    tipo character varying(15) NOT NULL,
    nombre_cobertura_social character varying(50)
);
 !   DROP TABLE public.no_voluntario;
       public         heap    postgres    false                       1259    31217    datos_familiares    VIEW     h  CREATE VIEW public.datos_familiares AS
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
    nv.nombre_cobertura_social,
    nv.nro_afiliado,
    nv.descripcion,
    ep.relacion,
    p.dni AS dni_paciente
   FROM ((((public.persona p
     LEFT JOIN public.telefono t ON ((p.dni = t.dni)))
     JOIN public.no_voluntario nv ON ((p.dni = nv.dni)))
     LEFT JOIN public.es_pariente ep ON ((p.dni = ep.dni_familiar)))
     JOIN public.persona p2 ON ((p2.dni = ep.dni_paciente)))
  ORDER BY p.apellido, p.nombre;
 #   DROP VIEW public.datos_familiares;
       public          postgres    false    244    252    252    244    244    244    244    244    244    244    244    244    240    240    240    240    230    230    230            �            1259    31140    paciente    TABLE     �   CREATE TABLE public.paciente (
    legajo_proceso_salud character varying(100) NOT NULL,
    legajo_socioeconomico character varying(100) NOT NULL,
    dni bigint NOT NULL
);
    DROP TABLE public.paciente;
       public         heap    postgres    false                       1259    31222    datos_pacientes_completos    VIEW     �  CREATE VIEW public.datos_pacientes_completos AS
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
    nv.nombre_cobertura_social,
    nv.nro_afiliado,
    nv.descripcion,
    pa.legajo_proceso_salud,
    pa.legajo_socioeconomico
   FROM ((public.persona p
     JOIN public.no_voluntario nv ON ((p.dni = nv.dni)))
     JOIN public.paciente pa ON ((p.dni = pa.dni)))
  ORDER BY p.apellido, p.nombre;
 ,   DROP VIEW public.datos_pacientes_completos;
       public          postgres    false    240    240    244    244    244    244    244    244    244    244    244    244    242    242    242    240    240            �            1259    31118    institucion    TABLE     t   CREATE TABLE public.institucion (
    id_institucion integer NOT NULL,
    nombre character varying(30) NOT NULL
);
    DROP TABLE public.institucion;
       public         heap    postgres    false            �            1259    31173    sede    TABLE       CREATE TABLE public.sede (
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL,
    ciudad character varying(15) NOT NULL,
    calle character varying(20) NOT NULL,
    numero integer NOT NULL,
    horario character varying(50),
    email character varying(40) NOT NULL
);
    DROP TABLE public.sede;
       public         heap    postgres    false            �            1259    31187    telefono_sede    TABLE     �   CREATE TABLE public.telefono_sede (
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL,
    telefono character varying(20) NOT NULL
);
 !   DROP TABLE public.telefono_sede;
       public         heap    postgres    false                       1259    31227    datos_sedes    VIEW     �  CREATE VIEW public.datos_sedes AS
 SELECT d.id_sede,
    d.id_institucion,
    i.nombre AS institucion_nombre,
    d.ciudad,
    d.calle,
    d.numero,
    d.email,
    d.horario,
    te.telefono
   FROM ((public.sede d
     JOIN public.institucion i ON ((d.id_institucion = i.id_institucion)))
     JOIN public.telefono_sede te ON (((d.id_sede = te.id_sede) AND (d.id_institucion = te.id_institucion))))
  ORDER BY d.id_sede;
    DROP VIEW public.datos_sedes;
       public          postgres    false    251    251    251    248    248    248    248    248    248    248    238    238            �            1259    31087    facebook_event_items    TABLE     �  CREATE TABLE public.facebook_event_items (
    id bigint NOT NULL,
    facebook_post_id bigint NOT NULL,
    tag character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT facebook_event_items_tag_check CHECK (((tag)::text = ANY ((ARRAY['tandil'::character varying, 'juarez'::character varying, 'next'::character varying])::text[])))
);
 (   DROP TABLE public.facebook_event_items;
       public         heap    postgres    false            �            1259    31086    facebook_event_items_id_seq    SEQUENCE     �   CREATE SEQUENCE public.facebook_event_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.facebook_event_items_id_seq;
       public          postgres    false    232            %           0    0    facebook_event_items_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.facebook_event_items_id_seq OWNED BY public.facebook_event_items.id;
          public          postgres    false    231            �            1259    31095    facebook_news_items    TABLE     �   CREATE TABLE public.facebook_news_items (
    id bigint NOT NULL,
    facebook_post_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 '   DROP TABLE public.facebook_news_items;
       public         heap    postgres    false            �            1259    31094    facebook_news_items_id_seq    SEQUENCE     �   CREATE SEQUENCE public.facebook_news_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.facebook_news_items_id_seq;
       public          postgres    false    234            &           0    0    facebook_news_items_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.facebook_news_items_id_seq OWNED BY public.facebook_news_items.id;
          public          postgres    false    233            �            1259    31102    failed_jobs    TABLE     &  CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
    DROP TABLE public.failed_jobs;
       public         heap    postgres    false            �            1259    31101    failed_jobs_id_seq    SEQUENCE     {   CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.failed_jobs_id_seq;
       public          postgres    false    236            '           0    0    failed_jobs_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;
          public          postgres    false    235            �            1259    31113    familiar    TABLE     :   CREATE TABLE public.familiar (
    dni bigint NOT NULL
);
    DROP TABLE public.familiar;
       public         heap    postgres    false            �            1259    31046    jano_por_todos    TABLE     �   CREATE TABLE public.jano_por_todos (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 "   DROP TABLE public.jano_por_todos;
       public         heap    postgres    false            �            1259    31045    jano_por_todos_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.jano_por_todos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.jano_por_todos_id_seq;
       public          postgres    false    223            (           0    0    jano_por_todos_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.jano_por_todos_id_seq OWNED BY public.jano_por_todos.id;
          public          postgres    false    222            �            1259    31016 
   migrations    TABLE     �   CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);
    DROP TABLE public.migrations;
       public         heap    postgres    false            �            1259    31015    migrations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.migrations_id_seq;
       public          postgres    false    217            )           0    0    migrations_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;
          public          postgres    false    216            �            1259    31145    password_reset_tokens    TABLE     �   CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);
 )   DROP TABLE public.password_reset_tokens;
       public         heap    postgres    false            �            1259    31034    personal_access_tokens    TABLE     �  CREATE TABLE public.personal_access_tokens (
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
 *   DROP TABLE public.personal_access_tokens;
       public         heap    postgres    false            �            1259    31033    personal_access_tokens_id_seq    SEQUENCE     �   CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.personal_access_tokens_id_seq;
       public          postgres    false    221            *           0    0    personal_access_tokens_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;
          public          postgres    false    220            �            1259    31165    professionals    TABLE     �  CREATE TABLE public.professionals (
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
 !   DROP TABLE public.professionals;
       public         heap    postgres    false            �            1259    31164    professionals_id_seq    SEQUENCE     }   CREATE SEQUENCE public.professionals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.professionals_id_seq;
       public          postgres    false    247            +           0    0    professionals_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.professionals_id_seq OWNED BY public.professionals.id;
          public          postgres    false    246            �            1259    31179    servicio    TABLE     �   CREATE TABLE public.servicio (
    id_servicio bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    id_sede integer NOT NULL,
    id_institucion integer NOT NULL,
    max_personas integer NOT NULL
);
    DROP TABLE public.servicio;
       public         heap    postgres    false            �            1259    31178    servicio_id_servicio_seq    SEQUENCE     �   CREATE SEQUENCE public.servicio_id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.servicio_id_servicio_seq;
       public          postgres    false    250            ,           0    0    servicio_id_servicio_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.servicio_id_servicio_seq OWNED BY public.servicio.id_servicio;
          public          postgres    false    249            �            1259    31023    users    TABLE     �  CREATE TABLE public.users (
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
    DROP TABLE public.users;
       public         heap    postgres    false            �            1259    31022    users_id_seq    SEQUENCE     u   CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    219            -           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    218                        2604    31076    contacts id    DEFAULT     j   ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);
 :   ALTER TABLE public.contacts ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    228    229                       2604    31090    facebook_event_items id    DEFAULT     �   ALTER TABLE ONLY public.facebook_event_items ALTER COLUMN id SET DEFAULT nextval('public.facebook_event_items_id_seq'::regclass);
 F   ALTER TABLE public.facebook_event_items ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    231    232    232                       2604    31098    facebook_news_items id    DEFAULT     �   ALTER TABLE ONLY public.facebook_news_items ALTER COLUMN id SET DEFAULT nextval('public.facebook_news_items_id_seq'::regclass);
 E   ALTER TABLE public.facebook_news_items ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    233    234    234                       2604    31105    failed_jobs id    DEFAULT     p   ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);
 =   ALTER TABLE public.failed_jobs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    235    236    236            �           2604    31049    jano_por_todos id    DEFAULT     v   ALTER TABLE ONLY public.jano_por_todos ALTER COLUMN id SET DEFAULT nextval('public.jano_por_todos_id_seq'::regclass);
 @   ALTER TABLE public.jano_por_todos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    223    223            �           2604    31019    migrations id    DEFAULT     n   ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);
 <   ALTER TABLE public.migrations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    217    217            �           2604    31037    personal_access_tokens id    DEFAULT     �   ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);
 H   ALTER TABLE public.personal_access_tokens ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    221    221                       2604    31168    professionals id    DEFAULT     t   ALTER TABLE ONLY public.professionals ALTER COLUMN id SET DEFAULT nextval('public.professionals_id_seq'::regclass);
 ?   ALTER TABLE public.professionals ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    246    247    247                       2604    31182    servicio id_servicio    DEFAULT     |   ALTER TABLE ONLY public.servicio ALTER COLUMN id_servicio SET DEFAULT nextval('public.servicio_id_servicio_seq'::regclass);
 C   ALTER TABLE public.servicio ALTER COLUMN id_servicio DROP DEFAULT;
       public          postgres    false    249    250    250            �           2604    31026    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    219    219            �          0    31052    atiende 
   TABLE DATA           @   COPY public.atiende (dni_paciente, dni_profesional) FROM stdin;
    public          postgres    false    224   C      �          0    31057    capacitacion 
   TABLE DATA           N   COPY public.capacitacion (capacitacion, fecha, otorgado_por, dni) FROM stdin;
    public          postgres    false    225   )C                 0    31062    cobertura_social 
   TABLE DATA           2   COPY public.cobertura_social (nombre) FROM stdin;
    public          postgres    false    226   FC                0    31067    colabora 
   TABLE DATA           M   COPY public.colabora (id_servicio, dni, id_sede, id_institucion) FROM stdin;
    public          postgres    false    227   cC                0    31073    contacts 
   TABLE DATA           Q   COPY public.contacts (id, "fullName", email, created_at, updated_at) FROM stdin;
    public          postgres    false    229   �C                0    31081    es_pariente 
   TABLE DATA           K   COPY public.es_pariente (dni_familiar, dni_paciente, relacion) FROM stdin;
    public          postgres    false    230   �C                0    31087    facebook_event_items 
   TABLE DATA           a   COPY public.facebook_event_items (id, facebook_post_id, tag, created_at, updated_at) FROM stdin;
    public          postgres    false    232   �C                0    31095    facebook_news_items 
   TABLE DATA           [   COPY public.facebook_news_items (id, facebook_post_id, created_at, updated_at) FROM stdin;
    public          postgres    false    234   8D      
          0    31102    failed_jobs 
   TABLE DATA           a   COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
    public          postgres    false    236   �D                0    31113    familiar 
   TABLE DATA           '   COPY public.familiar (dni) FROM stdin;
    public          postgres    false    237   �D                0    31118    institucion 
   TABLE DATA           =   COPY public.institucion (id_institucion, nombre) FROM stdin;
    public          postgres    false    238   �D      �          0    31046    jano_por_todos 
   TABLE DATA           D   COPY public.jano_por_todos (id, created_at, updated_at) FROM stdin;
    public          postgres    false    223   �D      �          0    31016 
   migrations 
   TABLE DATA           :   COPY public.migrations (id, migration, batch) FROM stdin;
    public          postgres    false    217   �D                0    31125    no_profesional 
   TABLE DATA           >   COPY public.no_profesional (area_desarrollo, dni) FROM stdin;
    public          postgres    false    239   G                0    31130    no_voluntario 
   TABLE DATA           f   COPY public.no_voluntario (nro_afiliado, descripcion, dni, tipo, nombre_cobertura_social) FROM stdin;
    public          postgres    false    240   :G                0    31135    oficio 
   TABLE DATA           -   COPY public.oficio (oficio, dni) FROM stdin;
    public          postgres    false    241   WG                0    31140    paciente 
   TABLE DATA           T   COPY public.paciente (legajo_proceso_salud, legajo_socioeconomico, dni) FROM stdin;
    public          postgres    false    242   tG                0    31145    password_reset_tokens 
   TABLE DATA           I   COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
    public          postgres    false    243   �G                0    31152    persona 
   TABLE DATA           s   COPY public.persona (dni, cuil, nombre, apellido, ciudad, calle, numero, depto, email, fecha_nac, rol) FROM stdin;
    public          postgres    false    244   �G      �          0    31034    personal_access_tokens 
   TABLE DATA           �   COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
    public          postgres    false    221   �G                0    31159    profesional 
   TABLE DATA           *   COPY public.profesional (dni) FROM stdin;
    public          postgres    false    245   �G                0    31165    professionals 
   TABLE DATA           �   COPY public.professionals (id, name, surname, birth_date, phone, city, email, profession, training, created_at, updated_at) FROM stdin;
    public          postgres    false    247   H                0    31173    sede 
   TABLE DATA           ^   COPY public.sede (id_sede, id_institucion, ciudad, calle, numero, horario, email) FROM stdin;
    public          postgres    false    248   "H                0    31179    servicio 
   TABLE DATA           ^   COPY public.servicio (id_servicio, nombre, id_sede, id_institucion, max_personas) FROM stdin;
    public          postgres    false    250   ?H                0    31192    telefono 
   TABLE DATA           1   COPY public.telefono (dni, telefono) FROM stdin;
    public          postgres    false    252   \H                0    31187    telefono_sede 
   TABLE DATA           J   COPY public.telefono_sede (id_sede, id_institucion, telefono) FROM stdin;
    public          postgres    false    251   yH                0    31197    titulo 
   TABLE DATA           :   COPY public.titulo (dni, titulo, tipo_titulo) FROM stdin;
    public          postgres    false    253   �H      �          0    31023    users 
   TABLE DATA           z   COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, rol) FROM stdin;
    public          postgres    false    219   �H                0    31202 
   voluntario 
   TABLE DATA           C   COPY public.voluntario (tipo, dni, remember_token, id) FROM stdin;
    public          postgres    false    254   SI      .           0    0    contacts_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.contacts_id_seq', 1, false);
          public          postgres    false    228            /           0    0    facebook_event_items_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.facebook_event_items_id_seq', 4, true);
          public          postgres    false    231            0           0    0    facebook_news_items_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.facebook_news_items_id_seq', 2, true);
          public          postgres    false    233            1           0    0    failed_jobs_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);
          public          postgres    false    235            2           0    0    jano_por_todos_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.jano_por_todos_id_seq', 1, false);
          public          postgres    false    222            3           0    0    migrations_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.migrations_id_seq', 48, true);
          public          postgres    false    216            4           0    0    personal_access_tokens_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);
          public          postgres    false    220            5           0    0    professionals_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.professionals_id_seq', 1, false);
          public          postgres    false    246            6           0    0    servicio_id_servicio_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.servicio_id_servicio_seq', 1, false);
          public          postgres    false    249            7           0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 1, true);
          public          postgres    false    218                       2606    31056    atiende atiende_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.atiende
    ADD CONSTRAINT atiende_pkey PRIMARY KEY (dni_paciente, dni_profesional);
 >   ALTER TABLE ONLY public.atiende DROP CONSTRAINT atiende_pkey;
       public            postgres    false    224    224                       2606    31061    capacitacion capacitacion_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.capacitacion
    ADD CONSTRAINT capacitacion_pkey PRIMARY KEY (dni, capacitacion);
 H   ALTER TABLE ONLY public.capacitacion DROP CONSTRAINT capacitacion_pkey;
       public            postgres    false    225    225                       2606    31066 &   cobertura_social cobertura_social_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.cobertura_social
    ADD CONSTRAINT cobertura_social_pkey PRIMARY KEY (nombre);
 P   ALTER TABLE ONLY public.cobertura_social DROP CONSTRAINT cobertura_social_pkey;
       public            postgres    false    226                       2606    31071    colabora colabora_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.colabora
    ADD CONSTRAINT colabora_pkey PRIMARY KEY (dni, id_servicio);
 @   ALTER TABLE ONLY public.colabora DROP CONSTRAINT colabora_pkey;
       public            postgres    false    227    227                       2606    31080    contacts contacts_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.contacts DROP CONSTRAINT contacts_pkey;
       public            postgres    false    229                        2606    31085    es_pariente es_pariente_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.es_pariente
    ADD CONSTRAINT es_pariente_pkey PRIMARY KEY (dni_familiar, dni_paciente);
 F   ALTER TABLE ONLY public.es_pariente DROP CONSTRAINT es_pariente_pkey;
       public            postgres    false    230    230            "           2606    31093 .   facebook_event_items facebook_event_items_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.facebook_event_items
    ADD CONSTRAINT facebook_event_items_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.facebook_event_items DROP CONSTRAINT facebook_event_items_pkey;
       public            postgres    false    232            $           2606    31100 ,   facebook_news_items facebook_news_items_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.facebook_news_items
    ADD CONSTRAINT facebook_news_items_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.facebook_news_items DROP CONSTRAINT facebook_news_items_pkey;
       public            postgres    false    234            &           2606    31110    failed_jobs failed_jobs_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.failed_jobs DROP CONSTRAINT failed_jobs_pkey;
       public            postgres    false    236            (           2606    31112 #   failed_jobs failed_jobs_uuid_unique 
   CONSTRAINT     ^   ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);
 M   ALTER TABLE ONLY public.failed_jobs DROP CONSTRAINT failed_jobs_uuid_unique;
       public            postgres    false    236            *           2606    31117    familiar familiar_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.familiar
    ADD CONSTRAINT familiar_pkey PRIMARY KEY (dni);
 @   ALTER TABLE ONLY public.familiar DROP CONSTRAINT familiar_pkey;
       public            postgres    false    237            ,           2606    31122    institucion institucion_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT institucion_pkey PRIMARY KEY (id_institucion);
 F   ALTER TABLE ONLY public.institucion DROP CONSTRAINT institucion_pkey;
       public            postgres    false    238                       2606    31051 "   jano_por_todos jano_por_todos_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.jano_por_todos
    ADD CONSTRAINT jano_por_todos_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.jano_por_todos DROP CONSTRAINT jano_por_todos_pkey;
       public            postgres    false    223            	           2606    31021    migrations migrations_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.migrations DROP CONSTRAINT migrations_pkey;
       public            postgres    false    217            0           2606    31129 "   no_profesional no_profesional_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.no_profesional
    ADD CONSTRAINT no_profesional_pkey PRIMARY KEY (dni);
 L   ALTER TABLE ONLY public.no_profesional DROP CONSTRAINT no_profesional_pkey;
       public            postgres    false    239            2           2606    31134     no_voluntario no_voluntario_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.no_voluntario
    ADD CONSTRAINT no_voluntario_pkey PRIMARY KEY (dni);
 J   ALTER TABLE ONLY public.no_voluntario DROP CONSTRAINT no_voluntario_pkey;
       public            postgres    false    240            4           2606    31139    oficio oficio_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.oficio
    ADD CONSTRAINT oficio_pkey PRIMARY KEY (dni, oficio);
 <   ALTER TABLE ONLY public.oficio DROP CONSTRAINT oficio_pkey;
       public            postgres    false    241    241            6           2606    31144    paciente paciente_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (dni);
 @   ALTER TABLE ONLY public.paciente DROP CONSTRAINT paciente_pkey;
       public            postgres    false    242            8           2606    31151 0   password_reset_tokens password_reset_tokens_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);
 Z   ALTER TABLE ONLY public.password_reset_tokens DROP CONSTRAINT password_reset_tokens_pkey;
       public            postgres    false    243            :           2606    31156    persona persona_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (dni);
 >   ALTER TABLE ONLY public.persona DROP CONSTRAINT persona_pkey;
       public            postgres    false    244                       2606    31041 2   personal_access_tokens personal_access_tokens_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.personal_access_tokens DROP CONSTRAINT personal_access_tokens_pkey;
       public            postgres    false    221                       2606    31044 :   personal_access_tokens personal_access_tokens_token_unique 
   CONSTRAINT     v   ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);
 d   ALTER TABLE ONLY public.personal_access_tokens DROP CONSTRAINT personal_access_tokens_token_unique;
       public            postgres    false    221            >           2606    31163    profesional profesional_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.profesional
    ADD CONSTRAINT profesional_pkey PRIMARY KEY (dni);
 F   ALTER TABLE ONLY public.profesional DROP CONSTRAINT profesional_pkey;
       public            postgres    false    245            @           2606    31172     professionals professionals_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.professionals DROP CONSTRAINT professionals_pkey;
       public            postgres    false    247            B           2606    31177    sede sede_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.sede
    ADD CONSTRAINT sede_pkey PRIMARY KEY (id_sede, id_institucion);
 8   ALTER TABLE ONLY public.sede DROP CONSTRAINT sede_pkey;
       public            postgres    false    248    248            D           2606    31184    servicio servicio_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT servicio_pkey PRIMARY KEY (id_servicio);
 @   ALTER TABLE ONLY public.servicio DROP CONSTRAINT servicio_pkey;
       public            postgres    false    250            J           2606    31196    telefono telefono_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.telefono
    ADD CONSTRAINT telefono_pkey PRIMARY KEY (dni, telefono);
 @   ALTER TABLE ONLY public.telefono DROP CONSTRAINT telefono_pkey;
       public            postgres    false    252    252            H           2606    31191     telefono_sede telefono_sede_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.telefono_sede
    ADD CONSTRAINT telefono_sede_pkey PRIMARY KEY (id_sede, id_institucion, telefono);
 J   ALTER TABLE ONLY public.telefono_sede DROP CONSTRAINT telefono_sede_pkey;
       public            postgres    false    251    251    251            L           2606    31201    titulo titulo_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.titulo
    ADD CONSTRAINT titulo_pkey PRIMARY KEY (dni, titulo);
 <   ALTER TABLE ONLY public.titulo DROP CONSTRAINT titulo_pkey;
       public            postgres    false    253    253            <           2606    31158    persona uq_cuil 
   CONSTRAINT     J   ALTER TABLE ONLY public.persona
    ADD CONSTRAINT uq_cuil UNIQUE (cuil);
 9   ALTER TABLE ONLY public.persona DROP CONSTRAINT uq_cuil;
       public            postgres    false    244            .           2606    31124 !   institucion uq_nombre_institucion 
   CONSTRAINT     ^   ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT uq_nombre_institucion UNIQUE (nombre);
 K   ALTER TABLE ONLY public.institucion DROP CONSTRAINT uq_nombre_institucion;
       public            postgres    false    238            F           2606    31186    servicio uq_nombre_serv 
   CONSTRAINT     T   ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT uq_nombre_serv UNIQUE (nombre);
 A   ALTER TABLE ONLY public.servicio DROP CONSTRAINT uq_nombre_serv;
       public            postgres    false    250                       2606    31032    users users_email_unique 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_unique;
       public            postgres    false    219                       2606    31030    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    219            N           2606    31206    voluntario voluntario_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.voluntario
    ADD CONSTRAINT voluntario_pkey PRIMARY KEY (dni);
 D   ALTER TABLE ONLY public.voluntario DROP CONSTRAINT voluntario_pkey;
       public            postgres    false    254                       1259    31042 8   personal_access_tokens_tokenable_type_tokenable_id_index    INDEX     �   CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);
 L   DROP INDEX public.personal_access_tokens_tokenable_type_tokenable_id_index;
       public            postgres    false    221    221            O           2606    31232    atiende fk_dni_atiende    FK CONSTRAINT     �   ALTER TABLE ONLY public.atiende
    ADD CONSTRAINT fk_dni_atiende FOREIGN KEY (dni_paciente) REFERENCES public.paciente(dni) ON UPDATE CASCADE ON DELETE RESTRICT;
 @   ALTER TABLE ONLY public.atiende DROP CONSTRAINT fk_dni_atiende;
       public          postgres    false    4918    224    242            Q           2606    31242     capacitacion fk_dni_capacitacion    FK CONSTRAINT     �   ALTER TABLE ONLY public.capacitacion
    ADD CONSTRAINT fk_dni_capacitacion FOREIGN KEY (dni) REFERENCES public.no_profesional(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.capacitacion DROP CONSTRAINT fk_dni_capacitacion;
       public          postgres    false    239    225    4912            R           2606    31247    colabora fk_dni_colabora    FK CONSTRAINT     �   ALTER TABLE ONLY public.colabora
    ADD CONSTRAINT fk_dni_colabora FOREIGN KEY (dni) REFERENCES public.voluntario(dni) ON UPDATE RESTRICT ON DELETE RESTRICT;
 B   ALTER TABLE ONLY public.colabora DROP CONSTRAINT fk_dni_colabora;
       public          postgres    false    227    254    4942            V           2606    31267    familiar fk_dni_familiar    FK CONSTRAINT     �   ALTER TABLE ONLY public.familiar
    ADD CONSTRAINT fk_dni_familiar FOREIGN KEY (dni) REFERENCES public.no_voluntario(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.familiar DROP CONSTRAINT fk_dni_familiar;
       public          postgres    false    237    4914    240            T           2606    31257 $   es_pariente fk_dni_familiar_pariente    FK CONSTRAINT     �   ALTER TABLE ONLY public.es_pariente
    ADD CONSTRAINT fk_dni_familiar_pariente FOREIGN KEY (dni_familiar) REFERENCES public.familiar(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 N   ALTER TABLE ONLY public.es_pariente DROP CONSTRAINT fk_dni_familiar_pariente;
       public          postgres    false    237    230    4906            W           2606    31272 "   no_voluntario fk_dni_no_voluntario    FK CONSTRAINT     �   ALTER TABLE ONLY public.no_voluntario
    ADD CONSTRAINT fk_dni_no_voluntario FOREIGN KEY (dni) REFERENCES public.persona(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.no_voluntario DROP CONSTRAINT fk_dni_no_voluntario;
       public          postgres    false    244    4922    240            Y           2606    31282    oficio fk_dni_oficio    FK CONSTRAINT     �   ALTER TABLE ONLY public.oficio
    ADD CONSTRAINT fk_dni_oficio FOREIGN KEY (dni) REFERENCES public.no_profesional(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.oficio DROP CONSTRAINT fk_dni_oficio;
       public          postgres    false    241    239    4912            Z           2606    31287    paciente fk_dni_paciente    FK CONSTRAINT     �   ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT fk_dni_paciente FOREIGN KEY (dni) REFERENCES public.no_voluntario(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.paciente DROP CONSTRAINT fk_dni_paciente;
       public          postgres    false    4914    240    242            U           2606    31262 $   es_pariente fk_dni_paciente_pariente    FK CONSTRAINT     �   ALTER TABLE ONLY public.es_pariente
    ADD CONSTRAINT fk_dni_paciente_pariente FOREIGN KEY (dni_paciente) REFERENCES public.paciente(dni) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.es_pariente DROP CONSTRAINT fk_dni_paciente_pariente;
       public          postgres    false    4918    230    242            [           2606    31292    profesional fk_dni_profesional    FK CONSTRAINT     �   ALTER TABLE ONLY public.profesional
    ADD CONSTRAINT fk_dni_profesional FOREIGN KEY (dni) REFERENCES public.voluntario(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.profesional DROP CONSTRAINT fk_dni_profesional;
       public          postgres    false    4942    245    254            P           2606    31237 "   atiende fk_dni_profesional_atiende    FK CONSTRAINT     �   ALTER TABLE ONLY public.atiende
    ADD CONSTRAINT fk_dni_profesional_atiende FOREIGN KEY (dni_profesional) REFERENCES public.profesional(dni) ON UPDATE CASCADE ON DELETE RESTRICT;
 L   ALTER TABLE ONLY public.atiende DROP CONSTRAINT fk_dni_profesional_atiende;
       public          postgres    false    224    245    4926            _           2606    31312    telefono fk_dni_telefono    FK CONSTRAINT     �   ALTER TABLE ONLY public.telefono
    ADD CONSTRAINT fk_dni_telefono FOREIGN KEY (dni) REFERENCES public.persona(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.telefono DROP CONSTRAINT fk_dni_telefono;
       public          postgres    false    252    4922    244            `           2606    31317    titulo fk_dni_titulo    FK CONSTRAINT     �   ALTER TABLE ONLY public.titulo
    ADD CONSTRAINT fk_dni_titulo FOREIGN KEY (dni) REFERENCES public.profesional(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.titulo DROP CONSTRAINT fk_dni_titulo;
       public          postgres    false    4926    245    253            a           2606    31322    voluntario fk_dni_voluntario    FK CONSTRAINT     �   ALTER TABLE ONLY public.voluntario
    ADD CONSTRAINT fk_dni_voluntario FOREIGN KEY (dni) REFERENCES public.persona(dni) ON UPDATE CASCADE ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.voluntario DROP CONSTRAINT fk_dni_voluntario;
       public          postgres    false    4922    244    254            \           2606    31297    sede fk_id_institucion    FK CONSTRAINT     �   ALTER TABLE ONLY public.sede
    ADD CONSTRAINT fk_id_institucion FOREIGN KEY (id_institucion) REFERENCES public.institucion(id_institucion) ON UPDATE CASCADE ON DELETE CASCADE;
 @   ALTER TABLE ONLY public.sede DROP CONSTRAINT fk_id_institucion;
       public          postgres    false    238    248    4908            X           2606    31277 /   no_voluntario fk_no_voluntario_cobertura_social    FK CONSTRAINT     �   ALTER TABLE ONLY public.no_voluntario
    ADD CONSTRAINT fk_no_voluntario_cobertura_social FOREIGN KEY (nombre_cobertura_social) REFERENCES public.cobertura_social(nombre);
 Y   ALTER TABLE ONLY public.no_voluntario DROP CONSTRAINT fk_no_voluntario_cobertura_social;
       public          postgres    false    4890    226    240            ]           2606    31302    servicio fk_servicio    FK CONSTRAINT     �   ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT fk_servicio FOREIGN KEY (id_sede, id_institucion) REFERENCES public.sede(id_sede, id_institucion) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.servicio DROP CONSTRAINT fk_servicio;
       public          postgres    false    4930    250    250    248    248            S           2606    31252    colabora fk_servicio_colabora    FK CONSTRAINT     �   ALTER TABLE ONLY public.colabora
    ADD CONSTRAINT fk_servicio_colabora FOREIGN KEY (id_servicio) REFERENCES public.servicio(id_servicio) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.colabora DROP CONSTRAINT fk_servicio_colabora;
       public          postgres    false    4932    227    250            ^           2606    31307    telefono_sede fk_telefono_sede    FK CONSTRAINT     �   ALTER TABLE ONLY public.telefono_sede
    ADD CONSTRAINT fk_telefono_sede FOREIGN KEY (id_sede, id_institucion) REFERENCES public.sede(id_sede, id_institucion) ON UPDATE RESTRICT ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.telefono_sede DROP CONSTRAINT fk_telefono_sede;
       public          postgres    false    251    4930    251    248    248            �      x������ � �      �      x������ � �             x������ � �            x������ � �            x������ � �            x������ � �         n   x���=�PE�z�*� �q��k�!�Bc(�6�^@��)�Y��ef�Y�^���)���1��9��{�
U3����Y@���I�t*�
GҬ��y|���{�L����6�         C   x��˻�0�:�����2K���SОt6��h�-�Pp*&����O�3�4��R�=�-"j=h      
      x������ � �            x������ � �            x������ � �      �      x������ � �      �     x���펪0E�scK��]n�8L:"%m����S�B�SN01&f/��V�ȳPZ�����|�ƃ��o|���=���L�ϔ��3'���97�^���������
IYi!�L��c"�����<"�˄Jf��x����Y&ZZ�����ƌ���n��oL�����\c�v&�czS;D������|���Yz4o5�[��|g���h�#�m�k�!�<�g{h������_mo��a�d;�h�mU�`�Ny�A�Og�)���o؈�.Lծ��2�4��[W�T=�η�C��=<�)����Y����#�~����0XKɴ��r_����6B�ö֗g���9̔�4�Q�Ԃ.��*�xk".Zm�m�5�ac+����G�IZ����/EM�\j:��ڰa&�N�u�!�7�T����q��Ҧmu�<دA_�'������*e�8��f���zE*��ᮨUe��dE+��9SԨ2��6E�)sd��h�,쑢�����.��QGe*��:jY$uԦ�<��"\���t:�D�(U            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �      �      x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �      �   �   x�3�tL�����J��/�/*�O�/vH�M���K���4202�50�5�T0��21�22�T1�T14RIN�./����*��ȏ0��J���K4/��O����̯	�wr-2�,w�p-L�Nw,�t��b�)V�D��b���� ��0�            x������ � �     