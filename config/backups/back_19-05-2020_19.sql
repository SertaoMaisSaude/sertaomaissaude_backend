PGDMP     3                    x            covid_19 %   10.12 (Ubuntu 10.12-0ubuntu0.18.04.1) "   10.12 (Ubuntu 10.12-2.pgdg16.04+1) �   y           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            z           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            {           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            |           1262    18736    covid_19    DATABASE     r   CREATE DATABASE covid_19 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';
    DROP DATABASE covid_19;
             postgres    false                        2615    19535    hdb_catalog    SCHEMA        CREATE SCHEMA hdb_catalog;
    DROP SCHEMA hdb_catalog;
             postgres    false                        2615    19536 	   hdb_views    SCHEMA        CREATE SCHEMA hdb_views;
    DROP SCHEMA hdb_views;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            }           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    4                        3079    13004    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            ~           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                        3079    19537    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                  false    4                       0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                       false    2            c           1255    19786    check_violation(text)    FUNCTION     �   CREATE FUNCTION hdb_catalog.check_violation(msg text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RAISE check_violation USING message=msg;
  END;
$$;
 5   DROP FUNCTION hdb_catalog.check_violation(msg text);
       hdb_catalog       postgres    false    1    8            a           1255    19734 "   hdb_schema_update_event_notifier()    FUNCTION     '  CREATE FUNCTION hdb_catalog.hdb_schema_update_event_notifier() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    instance_id uuid;
    occurred_at timestamptz;
    invalidations json;
    curr_rec record;
  BEGIN
    instance_id = NEW.instance_id;
    occurred_at = NEW.occurred_at;
    invalidations = NEW.invalidations;
    PERFORM pg_notify('hasura_schema_update', json_build_object(
      'instance_id', instance_id,
      'occurred_at', occurred_at,
      'invalidations', invalidations
      )::text);
    RETURN curr_rec;
  END;
$$;
 >   DROP FUNCTION hdb_catalog.hdb_schema_update_event_notifier();
       hdb_catalog       postgres    false    1    8            `           1255    19650 -   inject_table_defaults(text, text, text, text)    FUNCTION       CREATE FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        r RECORD;
    BEGIN
      FOR r IN SELECT column_name, column_default FROM information_schema.columns WHERE table_schema = tab_schema AND table_name = tab_name AND column_default IS NOT NULL LOOP
          EXECUTE format('ALTER VIEW %I.%I ALTER COLUMN %I SET DEFAULT %s;', view_schema, view_name, r.column_name, r.column_default);
      END LOOP;
    END;
$$;
 s   DROP FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text);
       hdb_catalog       postgres    false    1    8            b           1255    19746 .   insert_event_log(text, text, text, text, json)    FUNCTION     �  CREATE FUNCTION hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    id text;
    payload json;
    session_variables json;
    server_version_num int;
  BEGIN
    id := gen_random_uuid();
    server_version_num := current_setting('server_version_num');
    IF server_version_num >= 90600 THEN
      session_variables := current_setting('hasura.user', 't');
    ELSE
      BEGIN
        session_variables := current_setting('hasura.user');
      EXCEPTION WHEN OTHERS THEN
                  session_variables := NULL;
      END;
    END IF;
    payload := json_build_object(
      'op', op,
      'data', row_data,
      'session_variables', session_variables
    );
    INSERT INTO hdb_catalog.event_log
                (id, schema_name, table_name, trigger_name, payload)
    VALUES
    (id, schema_name, table_name, trigger_name, payload);
    RETURN id;
  END;
$$;
 z   DROP FUNCTION hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json);
       hdb_catalog       postgres    false    1    8                       1259    19682    event_invocation_logs    TABLE     �   CREATE TABLE hdb_catalog.event_invocation_logs (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp without time zone DEFAULT now()
);
 .   DROP TABLE hdb_catalog.event_invocation_logs;
       hdb_catalog         postgres    false    2    4    8                       1259    19664 	   event_log    TABLE       CREATE TABLE hdb_catalog.event_log (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    trigger_name text NOT NULL,
    payload jsonb NOT NULL,
    delivered boolean DEFAULT false NOT NULL,
    error boolean DEFAULT false NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    locked boolean DEFAULT false NOT NULL,
    next_retry_at timestamp without time zone,
    archived boolean DEFAULT false NOT NULL
);
 "   DROP TABLE hdb_catalog.event_log;
       hdb_catalog         postgres    false    2    4    8                       1259    19651    event_triggers    TABLE     �   CREATE TABLE hdb_catalog.event_triggers (
    name text NOT NULL,
    type text NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    configuration json,
    comment text
);
 '   DROP TABLE hdb_catalog.event_triggers;
       hdb_catalog         postgres    false    8                       1259    19756    hdb_allowlist    TABLE     E   CREATE TABLE hdb_catalog.hdb_allowlist (
    collection_name text
);
 &   DROP TABLE hdb_catalog.hdb_allowlist;
       hdb_catalog         postgres    false    8                       1259    19635    hdb_check_constraint    VIEW     �  CREATE VIEW hdb_catalog.hdb_check_constraint AS
 SELECT (n.nspname)::text AS table_schema,
    (ct.relname)::text AS table_name,
    (r.conname)::text AS constraint_name,
    pg_get_constraintdef(r.oid, true) AS "check"
   FROM ((pg_constraint r
     JOIN pg_class ct ON ((r.conrelid = ct.oid)))
     JOIN pg_namespace n ON ((ct.relnamespace = n.oid)))
  WHERE (r.contype = 'c'::"char");
 ,   DROP VIEW hdb_catalog.hdb_check_constraint;
       hdb_catalog       postgres    false    8                       1259    19769    hdb_computed_field    TABLE     �   CREATE TABLE hdb_catalog.hdb_computed_field (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    computed_field_name text NOT NULL,
    definition jsonb NOT NULL,
    comment text
);
 +   DROP TABLE hdb_catalog.hdb_computed_field;
       hdb_catalog         postgres    false    8                       1259    19782    hdb_computed_field_function    VIEW     �  CREATE VIEW hdb_catalog.hdb_computed_field_function AS
 SELECT hdb_computed_field.table_schema,
    hdb_computed_field.table_name,
    hdb_computed_field.computed_field_name,
        CASE
            WHEN (((hdb_computed_field.definition -> 'function'::text) ->> 'name'::text) IS NULL) THEN (hdb_computed_field.definition ->> 'function'::text)
            ELSE ((hdb_computed_field.definition -> 'function'::text) ->> 'name'::text)
        END AS function_name,
        CASE
            WHEN (((hdb_computed_field.definition -> 'function'::text) ->> 'schema'::text) IS NULL) THEN 'public'::text
            ELSE ((hdb_computed_field.definition -> 'function'::text) ->> 'schema'::text)
        END AS function_schema
   FROM hdb_catalog.hdb_computed_field;
 3   DROP VIEW hdb_catalog.hdb_computed_field_function;
       hdb_catalog       postgres    false    282    282    282    282    8            
           1259    19630    hdb_foreign_key_constraint    VIEW     ~  CREATE VIEW hdb_catalog.hdb_foreign_key_constraint AS
 SELECT (q.table_schema)::text AS table_schema,
    (q.table_name)::text AS table_name,
    (q.constraint_name)::text AS constraint_name,
    (min(q.constraint_oid))::integer AS constraint_oid,
    min((q.ref_table_table_schema)::text) AS ref_table_table_schema,
    min((q.ref_table)::text) AS ref_table,
    json_object_agg(ac.attname, afc.attname) AS column_mapping,
    min((q.confupdtype)::text) AS on_update,
    min((q.confdeltype)::text) AS on_delete,
    json_agg(ac.attname) AS columns,
    json_agg(afc.attname) AS ref_columns
   FROM ((( SELECT ctn.nspname AS table_schema,
            ct.relname AS table_name,
            r.conrelid AS table_id,
            r.conname AS constraint_name,
            r.oid AS constraint_oid,
            cftn.nspname AS ref_table_table_schema,
            cft.relname AS ref_table,
            r.confrelid AS ref_table_id,
            r.confupdtype,
            r.confdeltype,
            unnest(r.conkey) AS column_id,
            unnest(r.confkey) AS ref_column_id
           FROM ((((pg_constraint r
             JOIN pg_class ct ON ((r.conrelid = ct.oid)))
             JOIN pg_namespace ctn ON ((ct.relnamespace = ctn.oid)))
             JOIN pg_class cft ON ((r.confrelid = cft.oid)))
             JOIN pg_namespace cftn ON ((cft.relnamespace = cftn.oid)))
          WHERE (r.contype = 'f'::"char")) q
     JOIN pg_attribute ac ON (((q.column_id = ac.attnum) AND (q.table_id = ac.attrelid))))
     JOIN pg_attribute afc ON (((q.ref_column_id = afc.attnum) AND (q.ref_table_id = afc.attrelid))))
  GROUP BY q.table_schema, q.table_name, q.constraint_name;
 2   DROP VIEW hdb_catalog.hdb_foreign_key_constraint;
       hdb_catalog       postgres    false    8                       1259    19698    hdb_function    TABLE     �   CREATE TABLE hdb_catalog.hdb_function (
    function_schema text NOT NULL,
    function_name text NOT NULL,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_system_defined boolean DEFAULT false
);
 %   DROP TABLE hdb_catalog.hdb_function;
       hdb_catalog         postgres    false    8                       1259    19708    hdb_function_agg    VIEW     X  CREATE VIEW hdb_catalog.hdb_function_agg AS
 SELECT (p.proname)::text AS function_name,
    (pn.nspname)::text AS function_schema,
    pd.description,
        CASE
            WHEN (p.provariadic = (0)::oid) THEN false
            ELSE true
        END AS has_variadic,
        CASE
            WHEN ((p.provolatile)::text = ('i'::character(1))::text) THEN 'IMMUTABLE'::text
            WHEN ((p.provolatile)::text = ('s'::character(1))::text) THEN 'STABLE'::text
            WHEN ((p.provolatile)::text = ('v'::character(1))::text) THEN 'VOLATILE'::text
            ELSE NULL::text
        END AS function_type,
    pg_get_functiondef(p.oid) AS function_definition,
    (rtn.nspname)::text AS return_type_schema,
    (rt.typname)::text AS return_type_name,
    (rt.typtype)::text AS return_type_type,
    p.proretset AS returns_set,
    ( SELECT COALESCE(json_agg(json_build_object('schema', q.schema, 'name', q.name, 'type', q.type)), '[]'::json) AS "coalesce"
           FROM ( SELECT pt.typname AS name,
                    pns.nspname AS schema,
                    pt.typtype AS type,
                    pat.ordinality
                   FROM ((unnest(COALESCE(p.proallargtypes, (p.proargtypes)::oid[])) WITH ORDINALITY pat(oid, ordinality)
                     LEFT JOIN pg_type pt ON ((pt.oid = pat.oid)))
                     LEFT JOIN pg_namespace pns ON ((pt.typnamespace = pns.oid)))
                  ORDER BY pat.ordinality) q) AS input_arg_types,
    to_json(COALESCE(p.proargnames, ARRAY[]::text[])) AS input_arg_names,
    p.pronargdefaults AS default_args,
    (p.oid)::integer AS function_oid
   FROM ((((pg_proc p
     JOIN pg_namespace pn ON ((pn.oid = p.pronamespace)))
     JOIN pg_type rt ON ((rt.oid = p.prorettype)))
     JOIN pg_namespace rtn ON ((rtn.oid = rt.typnamespace)))
     LEFT JOIN pg_description pd ON ((p.oid = pd.objoid)))
  WHERE (((pn.nspname)::text !~~ 'pg_%'::text) AND ((pn.nspname)::text <> ALL (ARRAY['information_schema'::text, 'hdb_catalog'::text, 'hdb_views'::text])) AND (NOT (EXISTS ( SELECT 1
           FROM pg_aggregate
          WHERE ((pg_aggregate.aggfnoid)::oid = p.oid)))));
 (   DROP VIEW hdb_catalog.hdb_function_agg;
       hdb_catalog       postgres    false    8                       1259    19741    hdb_function_info_agg    VIEW       CREATE VIEW hdb_catalog.hdb_function_info_agg AS
 SELECT hdb_function_agg.function_name,
    hdb_function_agg.function_schema,
    row_to_json(( SELECT e.*::record AS e
           FROM ( SELECT hdb_function_agg.description,
                    hdb_function_agg.has_variadic,
                    hdb_function_agg.function_type,
                    hdb_function_agg.return_type_schema,
                    hdb_function_agg.return_type_name,
                    hdb_function_agg.return_type_type,
                    hdb_function_agg.returns_set,
                    hdb_function_agg.input_arg_types,
                    hdb_function_agg.input_arg_names,
                    hdb_function_agg.default_args,
                    (EXISTS ( SELECT 1
                           FROM information_schema.tables
                          WHERE (((tables.table_schema)::text = hdb_function_agg.return_type_schema) AND ((tables.table_name)::text = hdb_function_agg.return_type_name)))) AS returns_table) e)) AS function_info
   FROM hdb_catalog.hdb_function_agg;
 -   DROP VIEW hdb_catalog.hdb_function_info_agg;
       hdb_catalog       postgres    false    274    274    274    274    274    274    274    274    274    274    274    274    8                       1259    19611    hdb_permission    TABLE     �  CREATE TABLE hdb_catalog.hdb_permission (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    role_name text NOT NULL,
    perm_type text NOT NULL,
    perm_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_permission_perm_type_check CHECK ((perm_type = ANY (ARRAY['insert'::text, 'select'::text, 'update'::text, 'delete'::text])))
);
 '   DROP TABLE hdb_catalog.hdb_permission;
       hdb_catalog         postgres    false    8            	           1259    19626    hdb_permission_agg    VIEW     f  CREATE VIEW hdb_catalog.hdb_permission_agg AS
 SELECT hdb_permission.table_schema,
    hdb_permission.table_name,
    hdb_permission.role_name,
    json_object_agg(hdb_permission.perm_type, hdb_permission.perm_def) AS permissions
   FROM hdb_catalog.hdb_permission
  GROUP BY hdb_permission.table_schema, hdb_permission.table_name, hdb_permission.role_name;
 *   DROP VIEW hdb_catalog.hdb_permission_agg;
       hdb_catalog       postgres    false    264    264    264    264    264    8                       1259    19645    hdb_primary_key    VIEW     �	  CREATE VIEW hdb_catalog.hdb_primary_key AS
 SELECT tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    json_agg(constraint_column_usage.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN ( SELECT x.tblschema AS table_schema,
            x.tblname AS table_name,
            x.colname AS column_name,
            x.cstrname AS constraint_name
           FROM ( SELECT DISTINCT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_depend d,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (d.refclassid = ('pg_class'::regclass)::oid) AND (d.refobjid = r.oid) AND (d.refobjsubid = a.attnum) AND (d.classid = ('pg_constraint'::regclass)::oid) AND (d.objid = c.oid) AND (c.connamespace = nc.oid) AND (c.contype = 'c'::"char") AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND (NOT a.attisdropped))
                UNION ALL
                 SELECT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (nc.oid = c.connamespace) AND (r.oid =
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confrelid
                            ELSE c.conrelid
                        END) AND (a.attnum = ANY (
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confkey
                            ELSE c.conkey
                        END)) AND (NOT a.attisdropped) AND (c.contype = ANY (ARRAY['p'::"char", 'u'::"char", 'f'::"char"])) AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])))) x(tblschema, tblname, colname, cstrname)) constraint_column_usage ON ((((tc.constraint_name)::text = (constraint_column_usage.constraint_name)::text) AND ((tc.table_schema)::text = (constraint_column_usage.table_schema)::text) AND ((tc.table_name)::text = (constraint_column_usage.table_name)::text))))
  WHERE ((tc.constraint_type)::text = 'PRIMARY KEY'::text)
  GROUP BY tc.table_schema, tc.table_name, tc.constraint_name;
 '   DROP VIEW hdb_catalog.hdb_primary_key;
       hdb_catalog       postgres    false    8                       1259    19747    hdb_query_collection    TABLE     �   CREATE TABLE hdb_catalog.hdb_query_collection (
    collection_name text NOT NULL,
    collection_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);
 -   DROP TABLE hdb_catalog.hdb_query_collection;
       hdb_catalog         postgres    false    8                       1259    19596    hdb_relationship    TABLE     f  CREATE TABLE hdb_catalog.hdb_relationship (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    rel_name text NOT NULL,
    rel_type text,
    rel_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_relationship_rel_type_check CHECK ((rel_type = ANY (ARRAY['object'::text, 'array'::text])))
);
 )   DROP TABLE hdb_catalog.hdb_relationship;
       hdb_catalog         postgres    false    8                       1259    19726    hdb_schema_update_event    TABLE     �   CREATE TABLE hdb_catalog.hdb_schema_update_event (
    instance_id uuid NOT NULL,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL,
    invalidations json NOT NULL
);
 0   DROP TABLE hdb_catalog.hdb_schema_update_event;
       hdb_catalog         postgres    false    8                       1259    19586 	   hdb_table    TABLE     �   CREATE TABLE hdb_catalog.hdb_table (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    configuration jsonb,
    is_system_defined boolean DEFAULT false,
    is_enum boolean DEFAULT false NOT NULL
);
 "   DROP TABLE hdb_catalog.hdb_table;
       hdb_catalog         postgres    false    8                       1259    19736    hdb_table_info_agg    VIEW     �  CREATE VIEW hdb_catalog.hdb_table_info_agg AS
 SELECT schema.nspname AS table_schema,
    "table".relname AS table_name,
    jsonb_build_object('oid', ("table".oid)::integer, 'columns', COALESCE(columns.info, '[]'::jsonb), 'primary_key', primary_key.info, 'unique_constraints', COALESCE(unique_constraints.info, '[]'::jsonb), 'foreign_keys', COALESCE(foreign_key_constraints.info, '[]'::jsonb), 'view_info',
        CASE "table".relkind
            WHEN 'v'::"char" THEN jsonb_build_object('is_updatable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 4) = 4), 'is_insertable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 8) = 8), 'is_deletable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 16) = 16))
            ELSE NULL::jsonb
        END, 'description', description.description) AS info
   FROM ((((((pg_class "table"
     JOIN pg_namespace schema ON ((schema.oid = "table".relnamespace)))
     LEFT JOIN pg_description description ON (((description.classoid = ('pg_class'::regclass)::oid) AND (description.objoid = "table".oid) AND (description.objsubid = 0))))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('name', "column".attname, 'position', "column".attnum, 'type', COALESCE(base_type.typname, type.typname), 'is_nullable', (NOT "column".attnotnull), 'description', col_description("table".oid, ("column".attnum)::integer))) AS info
           FROM ((pg_attribute "column"
             LEFT JOIN pg_type type ON ((type.oid = "column".atttypid)))
             LEFT JOIN pg_type base_type ON (((type.typtype = 'd'::"char") AND (base_type.oid = type.typbasetype))))
          WHERE (("column".attrelid = "table".oid) AND ("column".attnum > 0) AND (NOT "column".attisdropped))) columns ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_build_object('constraint', jsonb_build_object('name', class.relname, 'oid', (class.oid)::integer), 'columns', COALESCE(columns_1.info, '[]'::jsonb)) AS info
           FROM ((pg_index index
             JOIN pg_class class ON ((class.oid = index.indexrelid)))
             LEFT JOIN LATERAL ( SELECT jsonb_agg("column".attname) AS info
                   FROM pg_attribute "column"
                  WHERE (("column".attrelid = "table".oid) AND ("column".attnum = ANY ((index.indkey)::smallint[])))) columns_1 ON (true))
          WHERE ((index.indrelid = "table".oid) AND index.indisprimary)) primary_key ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('name', class.relname, 'oid', (class.oid)::integer)) AS info
           FROM (pg_index index
             JOIN pg_class class ON ((class.oid = index.indexrelid)))
          WHERE ((index.indrelid = "table".oid) AND index.indisunique AND (NOT index.indisprimary))) unique_constraints ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('constraint', jsonb_build_object('name', foreign_key.constraint_name, 'oid', foreign_key.constraint_oid), 'columns', foreign_key.columns, 'foreign_table', jsonb_build_object('schema', foreign_key.ref_table_table_schema, 'name', foreign_key.ref_table), 'foreign_columns', foreign_key.ref_columns)) AS info
           FROM hdb_catalog.hdb_foreign_key_constraint foreign_key
          WHERE ((foreign_key.table_schema = (schema.nspname)::text) AND (foreign_key.table_name = ("table".relname)::text))) foreign_key_constraints ON (true))
  WHERE ("table".relkind = ANY (ARRAY['r'::"char", 't'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"]));
 *   DROP VIEW hdb_catalog.hdb_table_info_agg;
       hdb_catalog       postgres    false    266    266    266    266    266    266    266    266    8                       1259    19640    hdb_unique_constraint    VIEW     �  CREATE VIEW hdb_catalog.hdb_unique_constraint AS
 SELECT tc.table_name,
    tc.constraint_schema AS table_schema,
    tc.constraint_name,
    json_agg(kcu.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN information_schema.key_column_usage kcu USING (constraint_schema, constraint_name))
  WHERE ((tc.constraint_type)::text = 'UNIQUE'::text)
  GROUP BY tc.table_name, tc.constraint_schema, tc.constraint_name;
 -   DROP VIEW hdb_catalog.hdb_unique_constraint;
       hdb_catalog       postgres    false    8                       1259    19574    hdb_version    TABLE       CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);
 $   DROP TABLE hdb_catalog.hdb_version;
       hdb_catalog         postgres    false    2    4    8                       1259    19715    remote_schemas    TABLE     z   CREATE TABLE hdb_catalog.remote_schemas (
    id bigint NOT NULL,
    name text,
    definition json,
    comment text
);
 '   DROP TABLE hdb_catalog.remote_schemas;
       hdb_catalog         postgres    false    8                       1259    19713    remote_schemas_id_seq    SEQUENCE     �   CREATE SEQUENCE hdb_catalog.remote_schemas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE hdb_catalog.remote_schemas_id_seq;
       hdb_catalog       postgres    false    8    276            �           0    0    remote_schemas_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE hdb_catalog.remote_schemas_id_seq OWNED BY hdb_catalog.remote_schemas.id;
            hdb_catalog       postgres    false    275            �            1259    18773 
   auth_group    TABLE     f   CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);
    DROP TABLE public.auth_group;
       public         postgres    false    4            �            1259    18771    auth_group_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.auth_group_id_seq;
       public       postgres    false    206    4            �           0    0    auth_group_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;
            public       postgres    false    205            �            1259    18783    auth_group_permissions    TABLE     �   CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);
 *   DROP TABLE public.auth_group_permissions;
       public         postgres    false    4            �            1259    18781    auth_group_permissions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.auth_group_permissions_id_seq;
       public       postgres    false    208    4            �           0    0    auth_group_permissions_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;
            public       postgres    false    207            �            1259    18765    auth_permission    TABLE     �   CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);
 #   DROP TABLE public.auth_permission;
       public         postgres    false    4            �            1259    18763    auth_permission_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.auth_permission_id_seq;
       public       postgres    false    4    204            �           0    0    auth_permission_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;
            public       postgres    false    203            �            1259    18791 	   auth_user    TABLE     �  CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);
    DROP TABLE public.auth_user;
       public         postgres    false    4            �            1259    18801    auth_user_groups    TABLE        CREATE TABLE public.auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);
 $   DROP TABLE public.auth_user_groups;
       public         postgres    false    4            �            1259    18799    auth_user_groups_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.auth_user_groups_id_seq;
       public       postgres    false    4    212            �           0    0    auth_user_groups_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.auth_user_groups_id_seq OWNED BY public.auth_user_groups.id;
            public       postgres    false    211            �            1259    18789    auth_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.auth_user_id_seq;
       public       postgres    false    210    4            �           0    0    auth_user_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.auth_user_id_seq OWNED BY public.auth_user.id;
            public       postgres    false    209            �            1259    18809    auth_user_user_permissions    TABLE     �   CREATE TABLE public.auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);
 .   DROP TABLE public.auth_user_user_permissions;
       public         postgres    false    4            �            1259    18807 !   auth_user_user_permissions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.auth_user_user_permissions_id_seq;
       public       postgres    false    4    214            �           0    0 !   auth_user_user_permissions_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.auth_user_user_permissions_id_seq OWNED BY public.auth_user_user_permissions.id;
            public       postgres    false    213            �            1259    18900    authtoken_token    TABLE     �   CREATE TABLE public.authtoken_token (
    key character varying(40) NOT NULL,
    created timestamp with time zone NOT NULL,
    user_id integer NOT NULL
);
 #   DROP TABLE public.authtoken_token;
       public         postgres    false    4                       1259    19790    controle_atendimento_chat    TABLE     �   CREATE TABLE public.controle_atendimento_chat (
    id integer NOT NULL,
    active boolean NOT NULL,
    date timestamp with time zone NOT NULL,
    citizen_id integer NOT NULL,
    professional_id integer NOT NULL
);
 -   DROP TABLE public.controle_atendimento_chat;
       public         postgres    false    4                       1259    19788     controle_atendimento_chat_id_seq    SEQUENCE     �   CREATE SEQUENCE public.controle_atendimento_chat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.controle_atendimento_chat_id_seq;
       public       postgres    false    4    285            �           0    0     controle_atendimento_chat_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.controle_atendimento_chat_id_seq OWNED BY public.controle_atendimento_chat.id;
            public       postgres    false    284            #           1259    19818    controle_atendimento_message    TABLE     N  CREATE TABLE public.controle_atendimento_message (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    date_last_modification timestamp with time zone,
    message text NOT NULL,
    file character varying(100),
    received boolean NOT NULL,
    is_professional boolean NOT NULL,
    chat_id integer NOT NULL
);
 0   DROP TABLE public.controle_atendimento_message;
       public         postgres    false    4            "           1259    19816 #   controle_atendimento_message_id_seq    SEQUENCE     �   CREATE SEQUENCE public.controle_atendimento_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.controle_atendimento_message_id_seq;
       public       postgres    false    291    4            �           0    0 #   controle_atendimento_message_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.controle_atendimento_message_id_seq OWNED BY public.controle_atendimento_message.id;
            public       postgres    false    290            !           1259    19808    controle_atendimento_patient    TABLE     5  CREATE TABLE public.controle_atendimento_patient (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    date_last_modification timestamp with time zone,
    cpf character varying(50),
    sus_code character varying(50),
    status character varying(50),
    citizen_id integer NOT NULL
);
 0   DROP TABLE public.controle_atendimento_patient;
       public         postgres    false    4                        1259    19806 #   controle_atendimento_patient_id_seq    SEQUENCE     �   CREATE SEQUENCE public.controle_atendimento_patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.controle_atendimento_patient_id_seq;
       public       postgres    false    289    4            �           0    0 #   controle_atendimento_patient_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.controle_atendimento_patient_id_seq OWNED BY public.controle_atendimento_patient.id;
            public       postgres    false    288                       1259    19798    controle_atendimento_prontuario    TABLE     �   CREATE TABLE public.controle_atendimento_prontuario (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    date_last_modification timestamp with time zone,
    citizen_id integer NOT NULL,
    professional_id integer NOT NULL
);
 3   DROP TABLE public.controle_atendimento_prontuario;
       public         postgres    false    4                       1259    19796 &   controle_atendimento_prontuario_id_seq    SEQUENCE     �   CREATE SEQUENCE public.controle_atendimento_prontuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.controle_atendimento_prontuario_id_seq;
       public       postgres    false    287    4            �           0    0 &   controle_atendimento_prontuario_id_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.controle_atendimento_prontuario_id_seq OWNED BY public.controle_atendimento_prontuario.id;
            public       postgres    false    286            �            1259    18920    core_analisy    TABLE     �  CREATE TABLE public.core_analisy (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    has_faver boolean NOT NULL,
    fever numeric(3,1),
    citizen_id integer NOT NULL,
    "covidContact_id" integer NOT NULL,
    "latLng_id" integer,
    patient_situation character varying(255) NOT NULL,
    teleatend_status character varying(255) NOT NULL,
    "otherSympton" character varying(255)
);
     DROP TABLE public.core_analisy;
       public         postgres    false    4            �            1259    18918    core_analisy_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_analisy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.core_analisy_id_seq;
       public       postgres    false    4    219            �           0    0    core_analisy_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.core_analisy_id_seq OWNED BY public.core_analisy.id;
            public       postgres    false    218            �            1259    19108    core_analisy_listSympton    TABLE     �   CREATE TABLE public."core_analisy_listSympton" (
    id integer NOT NULL,
    analisy_id integer NOT NULL,
    sympton_id integer NOT NULL
);
 .   DROP TABLE public."core_analisy_listSympton";
       public         postgres    false    4            �            1259    19106    core_analisy_listSympton_id_seq    SEQUENCE     �   CREATE SEQUENCE public."core_analisy_listSympton_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public."core_analisy_listSympton_id_seq";
       public       postgres    false    255    4            �           0    0    core_analisy_listSympton_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public."core_analisy_listSympton_id_seq" OWNED BY public."core_analisy_listSympton".id;
            public       postgres    false    254            %           1259    20978    core_appversion    TABLE     �   CREATE TABLE public.core_appversion (
    id integer NOT NULL,
    version character varying(100) NOT NULL,
    active boolean NOT NULL,
    "fileVersion" character varying(100) NOT NULL
);
 #   DROP TABLE public.core_appversion;
       public         postgres    false    4            $           1259    20976    core_appversion_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_appversion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.core_appversion_id_seq;
       public       postgres    false    293    4            �           0    0    core_appversion_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.core_appversion_id_seq OWNED BY public.core_appversion.id;
            public       postgres    false    292                       1259    19477    core_blogpost    TABLE       CREATE TABLE public.core_blogpost (
    id integer NOT NULL,
    "postDate" timestamp with time zone NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    photo character varying(100),
    active boolean NOT NULL,
    city_id integer
);
 !   DROP TABLE public.core_blogpost;
       public         postgres    false    4                       1259    19475    core_blogpost_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_blogpost_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.core_blogpost_id_seq;
       public       postgres    false    260    4            �           0    0    core_blogpost_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.core_blogpost_id_seq OWNED BY public.core_blogpost.id;
            public       postgres    false    259            �            1259    18928    core_categorysympton    TABLE     �   CREATE TABLE public.core_categorysympton (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255)
);
 (   DROP TABLE public.core_categorysympton;
       public         postgres    false    4            �            1259    18926    core_categorysympton_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_categorysympton_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.core_categorysympton_id_seq;
       public       postgres    false    221    4            �           0    0    core_categorysympton_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.core_categorysympton_id_seq OWNED BY public.core_categorysympton.id;
            public       postgres    false    220            �            1259    19072    core_citizen    TABLE     �  CREATE TABLE public.core_citizen (
    id integer NOT NULL,
    "otherRiskGroup" character varying(255),
    name character varying(255),
    "phoneNumber" character varying(20) NOT NULL,
    cep character varying(8),
    city_id integer NOT NULL,
    "userProfile_id" integer,
    age integer,
    sex character varying(1),
    neighborhood character varying(255),
    street character varying(255),
    street_number character varying(255),
    "healthCenter_id" integer
);
     DROP TABLE public.core_citizen;
       public         postgres    false    4            �            1259    19070    core_citizen_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_citizen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.core_citizen_id_seq;
       public       postgres    false    4    251            �           0    0    core_citizen_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.core_citizen_id_seq OWNED BY public.core_citizen.id;
            public       postgres    false    250            �            1259    19085    core_citizen_listRiskGroup    TABLE     �   CREATE TABLE public."core_citizen_listRiskGroup" (
    id integer NOT NULL,
    citizen_id integer NOT NULL,
    riskgroup_id integer NOT NULL
);
 0   DROP TABLE public."core_citizen_listRiskGroup";
       public         postgres    false    4            �            1259    19083 !   core_citizen_listRiskGroup_id_seq    SEQUENCE     �   CREATE SEQUENCE public."core_citizen_listRiskGroup_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public."core_citizen_listRiskGroup_id_seq";
       public       postgres    false    4    253            �           0    0 !   core_citizen_listRiskGroup_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public."core_citizen_listRiskGroup_id_seq" OWNED BY public."core_citizen_listRiskGroup".id;
            public       postgres    false    252            �            1259    18939 	   core_city    TABLE     �   CREATE TABLE public.core_city (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "latLng_id" integer,
    active boolean NOT NULL
);
    DROP TABLE public.core_city;
       public         postgres    false    4            �            1259    18937    core_city_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.core_city_id_seq;
       public       postgres    false    223    4            �           0    0    core_city_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.core_city_id_seq OWNED BY public.core_city.id;
            public       postgres    false    222            �            1259    18947    core_covidcontact    TABLE     �   CREATE TABLE public.core_covidcontact (
    id integer NOT NULL,
    description character varying(255),
    active boolean NOT NULL,
    "typeContactCode" character varying(10)
);
 %   DROP TABLE public.core_covidcontact;
       public         postgres    false    4            �            1259    18945    core_covidcontact_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_covidcontact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.core_covidcontact_id_seq;
       public       postgres    false    225    4            �           0    0    core_covidcontact_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.core_covidcontact_id_seq OWNED BY public.core_covidcontact.id;
            public       postgres    false    224            �            1259    19059    core_dailynewsletter    TABLE     �  CREATE TABLE public.core_dailynewsletter (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    "underInvestigation" integer NOT NULL,
    waiting_exam integer NOT NULL,
    confirmed integer NOT NULL,
    recovered integer NOT NULL,
    deaths integer NOT NULL,
    city_id integer NOT NULL,
    discarded integer NOT NULL,
    date_publication timestamp with time zone,
    active boolean NOT NULL
);
 (   DROP TABLE public.core_dailynewsletter;
       public         postgres    false    4            �            1259    19057    core_dailynewsletter_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_dailynewsletter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.core_dailynewsletter_id_seq;
       public       postgres    false    249    4            �           0    0    core_dailynewsletter_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.core_dailynewsletter_id_seq OWNED BY public.core_dailynewsletter.id;
            public       postgres    false    248            �            1259    18955    core_disease    TABLE     �   CREATE TABLE public.core_disease (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255)
);
     DROP TABLE public.core_disease;
       public         postgres    false    4            �            1259    18953    core_disease_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_disease_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.core_disease_id_seq;
       public       postgres    false    227    4            �           0    0    core_disease_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.core_disease_id_seq OWNED BY public.core_disease.id;
            public       postgres    false    226            �            1259    19051    core_disease_listSympton    TABLE     �   CREATE TABLE public."core_disease_listSympton" (
    id integer NOT NULL,
    disease_id integer NOT NULL,
    sympton_id integer NOT NULL
);
 .   DROP TABLE public."core_disease_listSympton";
       public         postgres    false    4            �            1259    19049    core_disease_listSympton_id_seq    SEQUENCE     �   CREATE SEQUENCE public."core_disease_listSympton_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public."core_disease_listSympton_id_seq";
       public       postgres    false    247    4            �           0    0    core_disease_listSympton_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public."core_disease_listSympton_id_seq" OWNED BY public."core_disease_listSympton".id;
            public       postgres    false    246            �            1259    19032    core_healthcenter    TABLE     �  CREATE TABLE public.core_healthcenter (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    street character varying(255) NOT NULL,
    street_number character varying(255) NOT NULL,
    neighborhood character varying(255) NOT NULL,
    phone_number character varying(255),
    city_id integer NOT NULL,
    "latLng_id" integer,
    coverage character varying(255),
    active boolean NOT NULL
);
 %   DROP TABLE public.core_healthcenter;
       public         postgres    false    4            �            1259    19030    core_healthcenter_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_healthcenter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.core_healthcenter_id_seq;
       public       postgres    false    243    4            �           0    0    core_healthcenter_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.core_healthcenter_id_seq OWNED BY public.core_healthcenter.id;
            public       postgres    false    242            �            1259    19043 "   core_healthcenter_listProfessional    TABLE     �   CREATE TABLE public."core_healthcenter_listProfessional" (
    id integer NOT NULL,
    healthcenter_id integer NOT NULL,
    professional_id integer NOT NULL
);
 8   DROP TABLE public."core_healthcenter_listProfessional";
       public         postgres    false    4            �            1259    19041 )   core_healthcenter_listProfessional_id_seq    SEQUENCE     �   CREATE SEQUENCE public."core_healthcenter_listProfessional_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE public."core_healthcenter_listProfessional_id_seq";
       public       postgres    false    245    4            �           0    0 )   core_healthcenter_listProfessional_id_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE public."core_healthcenter_listProfessional_id_seq" OWNED BY public."core_healthcenter_listProfessional".id;
            public       postgres    false    244                       1259    19335    core_healthtips    TABLE     �   CREATE TABLE public.core_healthtips (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    photo character varying(100),
    active boolean NOT NULL,
    city_id integer
);
 #   DROP TABLE public.core_healthtips;
       public         postgres    false    4                        1259    19333    core_healthtips_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_healthtips_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.core_healthtips_id_seq;
       public       postgres    false    257    4            �           0    0    core_healthtips_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.core_healthtips_id_seq OWNED BY public.core_healthtips.id;
            public       postgres    false    256            �            1259    18966    core_latlng    TABLE     �   CREATE TABLE public.core_latlng (
    id integer NOT NULL,
    lat character varying(255) NOT NULL,
    lng character varying(255) NOT NULL
);
    DROP TABLE public.core_latlng;
       public         postgres    false    4            �            1259    18964    core_latlng_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_latlng_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.core_latlng_id_seq;
       public       postgres    false    4    229            �           0    0    core_latlng_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.core_latlng_id_seq OWNED BY public.core_latlng.id;
            public       postgres    false    228            '           1259    21299    core_partner    TABLE       CREATE TABLE public.core_partner (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    "phoneNumber" character varying(15) NOT NULL,
    resume character varying(1000) NOT NULL,
    photo character varying(100)
);
     DROP TABLE public.core_partner;
       public         postgres    false    4            &           1259    21297    core_partner_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_partner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.core_partner_id_seq;
       public       postgres    false    295    4            �           0    0    core_partner_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.core_partner_id_seq OWNED BY public.core_partner.id;
            public       postgres    false    294            �            1259    19022    core_professional    TABLE     X  CREATE TABLE public.core_professional (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "typeProfessional_id" integer NOT NULL,
    user_id integer,
    email character varying(100),
    "firstAccess" boolean NOT NULL,
    "phoneNumber" character varying(20) NOT NULL,
    active boolean NOT NULL,
    city_id integer
);
 %   DROP TABLE public.core_professional;
       public         postgres    false    4            �            1259    19020    core_professional_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_professional_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.core_professional_id_seq;
       public       postgres    false    241    4            �           0    0    core_professional_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.core_professional_id_seq OWNED BY public.core_professional.id;
            public       postgres    false    240            �            1259    19014    core_riskanalisy    TABLE     �   CREATE TABLE public.core_riskanalisy (
    id integer NOT NULL,
    analisy_id integer NOT NULL,
    disease_id integer NOT NULL
);
 $   DROP TABLE public.core_riskanalisy;
       public         postgres    false    4            �            1259    19012    core_riskanalisy_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_riskanalisy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.core_riskanalisy_id_seq;
       public       postgres    false    4    239            �           0    0    core_riskanalisy_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.core_riskanalisy_id_seq OWNED BY public.core_riskanalisy.id;
            public       postgres    false    238            �            1259    18977    core_riskgroup    TABLE     j   CREATE TABLE public.core_riskgroup (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);
 "   DROP TABLE public.core_riskgroup;
       public         postgres    false    4            �            1259    18975    core_riskgroup_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_riskgroup_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.core_riskgroup_id_seq;
       public       postgres    false    231    4            �           0    0    core_riskgroup_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.core_riskgroup_id_seq OWNED BY public.core_riskgroup.id;
            public       postgres    false    230            �            1259    19003    core_sympton    TABLE     �   CREATE TABLE public.core_sympton (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    category_id integer NOT NULL
);
     DROP TABLE public.core_sympton;
       public         postgres    false    4            �            1259    19001    core_sympton_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_sympton_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.core_sympton_id_seq;
       public       postgres    false    237    4            �           0    0    core_sympton_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.core_sympton_id_seq OWNED BY public.core_sympton.id;
            public       postgres    false    236            +           1259    21331 	   core_team    TABLE     ;   CREATE TABLE public.core_team (
    id integer NOT NULL
);
    DROP TABLE public.core_team;
       public         postgres    false    4            *           1259    21329    core_team_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.core_team_id_seq;
       public       postgres    false    4    299            �           0    0    core_team_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.core_team_id_seq OWNED BY public.core_team.id;
            public       postgres    false    298            -           1259    21339    core_team_partners    TABLE     �   CREATE TABLE public.core_team_partners (
    id integer NOT NULL,
    team_id integer NOT NULL,
    partner_id integer NOT NULL
);
 &   DROP TABLE public.core_team_partners;
       public         postgres    false    4            ,           1259    21337    core_team_partners_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_team_partners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.core_team_partners_id_seq;
       public       postgres    false    301    4            �           0    0    core_team_partners_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.core_team_partners_id_seq OWNED BY public.core_team_partners.id;
            public       postgres    false    300            /           1259    21347    core_team_teamMembers    TABLE     �   CREATE TABLE public."core_team_teamMembers" (
    id integer NOT NULL,
    team_id integer NOT NULL,
    teammember_id integer NOT NULL
);
 +   DROP TABLE public."core_team_teamMembers";
       public         postgres    false    4            .           1259    21345    core_team_teamMembers_id_seq    SEQUENCE     �   CREATE SEQUENCE public."core_team_teamMembers_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public."core_team_teamMembers_id_seq";
       public       postgres    false    4    303            �           0    0    core_team_teamMembers_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public."core_team_teamMembers_id_seq" OWNED BY public."core_team_teamMembers".id;
            public       postgres    false    302            )           1259    21310    core_teammember    TABLE       CREATE TABLE public.core_teammember (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    "phoneNumber" character varying(15) NOT NULL,
    resume character varying(1000) NOT NULL,
    photo character varying(100)
);
 #   DROP TABLE public.core_teammember;
       public         postgres    false    4            (           1259    21308    core_teammember_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_teammember_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.core_teammember_id_seq;
       public       postgres    false    4    297            �           0    0    core_teammember_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.core_teammember_id_seq OWNED BY public.core_teammember.id;
            public       postgres    false    296            �            1259    18985    core_typeprofessional    TABLE     �   CREATE TABLE public.core_typeprofessional (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "codeDocumentType" character varying(50),
    "userGroup_id" integer NOT NULL
);
 )   DROP TABLE public.core_typeprofessional;
       public         postgres    false    4            �            1259    18983    core_typeprofessional_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_typeprofessional_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.core_typeprofessional_id_seq;
       public       postgres    false    233    4            �           0    0    core_typeprofessional_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.core_typeprofessional_id_seq OWNED BY public.core_typeprofessional.id;
            public       postgres    false    232            �            1259    18993    core_userprofile    TABLE     l   CREATE TABLE public.core_userprofile (
    id integer NOT NULL,
    city_id integer,
    user_id integer
);
 $   DROP TABLE public.core_userprofile;
       public         postgres    false    4            �            1259    18991    core_userprofile_id_seq    SEQUENCE     �   CREATE SEQUENCE public.core_userprofile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.core_userprofile_id_seq;
       public       postgres    false    4    235            �           0    0    core_userprofile_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.core_userprofile_id_seq OWNED BY public.core_userprofile.id;
            public       postgres    false    234            �            1259    18869    django_admin_log    TABLE     �  CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);
 $   DROP TABLE public.django_admin_log;
       public         postgres    false    4            �            1259    18867    django_admin_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.django_admin_log_id_seq;
       public       postgres    false    216    4            �           0    0    django_admin_log_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;
            public       postgres    false    215            �            1259    18755    django_content_type    TABLE     �   CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);
 '   DROP TABLE public.django_content_type;
       public         postgres    false    4            �            1259    18753    django_content_type_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.django_content_type_id_seq;
       public       postgres    false    4    202            �           0    0    django_content_type_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;
            public       postgres    false    201            �            1259    18744    django_migrations    TABLE     �   CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);
 %   DROP TABLE public.django_migrations;
       public         postgres    false    4            �            1259    18742    django_migrations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.django_migrations_id_seq;
       public       postgres    false    4    200            �           0    0    django_migrations_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;
            public       postgres    false    199                       1259    19344    django_session    TABLE     �   CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);
 "   DROP TABLE public.django_session;
       public         postgres    false    4            �           2604    19718    remote_schemas id    DEFAULT     �   ALTER TABLE ONLY hdb_catalog.remote_schemas ALTER COLUMN id SET DEFAULT nextval('hdb_catalog.remote_schemas_id_seq'::regclass);
 E   ALTER TABLE hdb_catalog.remote_schemas ALTER COLUMN id DROP DEFAULT;
       hdb_catalog       postgres    false    276    275    276            U           2604    18776    auth_group id    DEFAULT     n   ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);
 <   ALTER TABLE public.auth_group ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    205    206    206            V           2604    18786    auth_group_permissions id    DEFAULT     �   ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);
 H   ALTER TABLE public.auth_group_permissions ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    208    207    208            T           2604    18768    auth_permission id    DEFAULT     x   ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);
 A   ALTER TABLE public.auth_permission ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    203    204    204            W           2604    18794    auth_user id    DEFAULT     l   ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);
 ;   ALTER TABLE public.auth_user ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    210    209    210            X           2604    18804    auth_user_groups id    DEFAULT     z   ALTER TABLE ONLY public.auth_user_groups ALTER COLUMN id SET DEFAULT nextval('public.auth_user_groups_id_seq'::regclass);
 B   ALTER TABLE public.auth_user_groups ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    212    211    212            Y           2604    18812    auth_user_user_permissions id    DEFAULT     �   ALTER TABLE ONLY public.auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_permissions_id_seq'::regclass);
 L   ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    213    214    214            �           2604    19793    controle_atendimento_chat id    DEFAULT     �   ALTER TABLE ONLY public.controle_atendimento_chat ALTER COLUMN id SET DEFAULT nextval('public.controle_atendimento_chat_id_seq'::regclass);
 K   ALTER TABLE public.controle_atendimento_chat ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    284    285    285            �           2604    19821    controle_atendimento_message id    DEFAULT     �   ALTER TABLE ONLY public.controle_atendimento_message ALTER COLUMN id SET DEFAULT nextval('public.controle_atendimento_message_id_seq'::regclass);
 N   ALTER TABLE public.controle_atendimento_message ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    290    291    291            �           2604    19811    controle_atendimento_patient id    DEFAULT     �   ALTER TABLE ONLY public.controle_atendimento_patient ALTER COLUMN id SET DEFAULT nextval('public.controle_atendimento_patient_id_seq'::regclass);
 N   ALTER TABLE public.controle_atendimento_patient ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    288    289    289            �           2604    19801 "   controle_atendimento_prontuario id    DEFAULT     �   ALTER TABLE ONLY public.controle_atendimento_prontuario ALTER COLUMN id SET DEFAULT nextval('public.controle_atendimento_prontuario_id_seq'::regclass);
 Q   ALTER TABLE public.controle_atendimento_prontuario ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    286    287    287            \           2604    18923    core_analisy id    DEFAULT     r   ALTER TABLE ONLY public.core_analisy ALTER COLUMN id SET DEFAULT nextval('public.core_analisy_id_seq'::regclass);
 >   ALTER TABLE public.core_analisy ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    218    219    219            n           2604    19111    core_analisy_listSympton id    DEFAULT     �   ALTER TABLE ONLY public."core_analisy_listSympton" ALTER COLUMN id SET DEFAULT nextval('public."core_analisy_listSympton_id_seq"'::regclass);
 L   ALTER TABLE public."core_analisy_listSympton" ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    254    255    255            �           2604    20981    core_appversion id    DEFAULT     x   ALTER TABLE ONLY public.core_appversion ALTER COLUMN id SET DEFAULT nextval('public.core_appversion_id_seq'::regclass);
 A   ALTER TABLE public.core_appversion ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    292    293    293            p           2604    19480    core_blogpost id    DEFAULT     t   ALTER TABLE ONLY public.core_blogpost ALTER COLUMN id SET DEFAULT nextval('public.core_blogpost_id_seq'::regclass);
 ?   ALTER TABLE public.core_blogpost ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    260    259    260            ]           2604    18931    core_categorysympton id    DEFAULT     �   ALTER TABLE ONLY public.core_categorysympton ALTER COLUMN id SET DEFAULT nextval('public.core_categorysympton_id_seq'::regclass);
 F   ALTER TABLE public.core_categorysympton ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    221    220    221            l           2604    19075    core_citizen id    DEFAULT     r   ALTER TABLE ONLY public.core_citizen ALTER COLUMN id SET DEFAULT nextval('public.core_citizen_id_seq'::regclass);
 >   ALTER TABLE public.core_citizen ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    251    250    251            m           2604    19088    core_citizen_listRiskGroup id    DEFAULT     �   ALTER TABLE ONLY public."core_citizen_listRiskGroup" ALTER COLUMN id SET DEFAULT nextval('public."core_citizen_listRiskGroup_id_seq"'::regclass);
 N   ALTER TABLE public."core_citizen_listRiskGroup" ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    253    252    253            ^           2604    18942    core_city id    DEFAULT     l   ALTER TABLE ONLY public.core_city ALTER COLUMN id SET DEFAULT nextval('public.core_city_id_seq'::regclass);
 ;   ALTER TABLE public.core_city ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    222    223    223            _           2604    18950    core_covidcontact id    DEFAULT     |   ALTER TABLE ONLY public.core_covidcontact ALTER COLUMN id SET DEFAULT nextval('public.core_covidcontact_id_seq'::regclass);
 C   ALTER TABLE public.core_covidcontact ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    225    224    225            k           2604    19062    core_dailynewsletter id    DEFAULT     �   ALTER TABLE ONLY public.core_dailynewsletter ALTER COLUMN id SET DEFAULT nextval('public.core_dailynewsletter_id_seq'::regclass);
 F   ALTER TABLE public.core_dailynewsletter ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    248    249    249            `           2604    18958    core_disease id    DEFAULT     r   ALTER TABLE ONLY public.core_disease ALTER COLUMN id SET DEFAULT nextval('public.core_disease_id_seq'::regclass);
 >   ALTER TABLE public.core_disease ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    226    227    227            j           2604    19054    core_disease_listSympton id    DEFAULT     �   ALTER TABLE ONLY public."core_disease_listSympton" ALTER COLUMN id SET DEFAULT nextval('public."core_disease_listSympton_id_seq"'::regclass);
 L   ALTER TABLE public."core_disease_listSympton" ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    247    246    247            h           2604    19035    core_healthcenter id    DEFAULT     |   ALTER TABLE ONLY public.core_healthcenter ALTER COLUMN id SET DEFAULT nextval('public.core_healthcenter_id_seq'::regclass);
 C   ALTER TABLE public.core_healthcenter ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    242    243    243            i           2604    19046 %   core_healthcenter_listProfessional id    DEFAULT     �   ALTER TABLE ONLY public."core_healthcenter_listProfessional" ALTER COLUMN id SET DEFAULT nextval('public."core_healthcenter_listProfessional_id_seq"'::regclass);
 V   ALTER TABLE public."core_healthcenter_listProfessional" ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    245    244    245            o           2604    19338    core_healthtips id    DEFAULT     x   ALTER TABLE ONLY public.core_healthtips ALTER COLUMN id SET DEFAULT nextval('public.core_healthtips_id_seq'::regclass);
 A   ALTER TABLE public.core_healthtips ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    257    256    257            a           2604    18969    core_latlng id    DEFAULT     p   ALTER TABLE ONLY public.core_latlng ALTER COLUMN id SET DEFAULT nextval('public.core_latlng_id_seq'::regclass);
 =   ALTER TABLE public.core_latlng ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    229    228    229            �           2604    21302    core_partner id    DEFAULT     r   ALTER TABLE ONLY public.core_partner ALTER COLUMN id SET DEFAULT nextval('public.core_partner_id_seq'::regclass);
 >   ALTER TABLE public.core_partner ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    294    295    295            g           2604    19025    core_professional id    DEFAULT     |   ALTER TABLE ONLY public.core_professional ALTER COLUMN id SET DEFAULT nextval('public.core_professional_id_seq'::regclass);
 C   ALTER TABLE public.core_professional ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    240    241    241            f           2604    19017    core_riskanalisy id    DEFAULT     z   ALTER TABLE ONLY public.core_riskanalisy ALTER COLUMN id SET DEFAULT nextval('public.core_riskanalisy_id_seq'::regclass);
 B   ALTER TABLE public.core_riskanalisy ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    239    238    239            b           2604    18980    core_riskgroup id    DEFAULT     v   ALTER TABLE ONLY public.core_riskgroup ALTER COLUMN id SET DEFAULT nextval('public.core_riskgroup_id_seq'::regclass);
 @   ALTER TABLE public.core_riskgroup ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    230    231    231            e           2604    19006    core_sympton id    DEFAULT     r   ALTER TABLE ONLY public.core_sympton ALTER COLUMN id SET DEFAULT nextval('public.core_sympton_id_seq'::regclass);
 >   ALTER TABLE public.core_sympton ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    236    237    237            �           2604    21334    core_team id    DEFAULT     l   ALTER TABLE ONLY public.core_team ALTER COLUMN id SET DEFAULT nextval('public.core_team_id_seq'::regclass);
 ;   ALTER TABLE public.core_team ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    298    299    299            �           2604    21342    core_team_partners id    DEFAULT     ~   ALTER TABLE ONLY public.core_team_partners ALTER COLUMN id SET DEFAULT nextval('public.core_team_partners_id_seq'::regclass);
 D   ALTER TABLE public.core_team_partners ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    300    301    301            �           2604    21350    core_team_teamMembers id    DEFAULT     �   ALTER TABLE ONLY public."core_team_teamMembers" ALTER COLUMN id SET DEFAULT nextval('public."core_team_teamMembers_id_seq"'::regclass);
 I   ALTER TABLE public."core_team_teamMembers" ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    302    303    303            �           2604    21313    core_teammember id    DEFAULT     x   ALTER TABLE ONLY public.core_teammember ALTER COLUMN id SET DEFAULT nextval('public.core_teammember_id_seq'::regclass);
 A   ALTER TABLE public.core_teammember ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    297    296    297            c           2604    18988    core_typeprofessional id    DEFAULT     �   ALTER TABLE ONLY public.core_typeprofessional ALTER COLUMN id SET DEFAULT nextval('public.core_typeprofessional_id_seq'::regclass);
 G   ALTER TABLE public.core_typeprofessional ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    232    233    233            d           2604    18996    core_userprofile id    DEFAULT     z   ALTER TABLE ONLY public.core_userprofile ALTER COLUMN id SET DEFAULT nextval('public.core_userprofile_id_seq'::regclass);
 B   ALTER TABLE public.core_userprofile ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    234    235    235            Z           2604    18872    django_admin_log id    DEFAULT     z   ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);
 B   ALTER TABLE public.django_admin_log ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    216    215    216            S           2604    18758    django_content_type id    DEFAULT     �   ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);
 E   ALTER TABLE public.django_content_type ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    201    202    202            R           2604    18747    django_migrations id    DEFAULT     |   ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);
 C   ALTER TABLE public.django_migrations ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    200    199    200            [          0    19682    event_invocation_logs 
   TABLE DATA               i   COPY hdb_catalog.event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
    hdb_catalog       postgres    false    272   u�      Z          0    19664 	   event_log 
   TABLE DATA               �   COPY hdb_catalog.event_log (id, schema_name, table_name, trigger_name, payload, delivered, error, tries, created_at, locked, next_retry_at, archived) FROM stdin;
    hdb_catalog       postgres    false    271   ��      Y          0    19651    event_triggers 
   TABLE DATA               j   COPY hdb_catalog.event_triggers (name, type, schema_name, table_name, configuration, comment) FROM stdin;
    hdb_catalog       postgres    false    270   ��      a          0    19756    hdb_allowlist 
   TABLE DATA               =   COPY hdb_catalog.hdb_allowlist (collection_name) FROM stdin;
    hdb_catalog       postgres    false    281   ��      b          0    19769    hdb_computed_field 
   TABLE DATA               u   COPY hdb_catalog.hdb_computed_field (table_schema, table_name, computed_field_name, definition, comment) FROM stdin;
    hdb_catalog       postgres    false    282   ��      \          0    19698    hdb_function 
   TABLE DATA               m   COPY hdb_catalog.hdb_function (function_schema, function_name, configuration, is_system_defined) FROM stdin;
    hdb_catalog       postgres    false    273   �      X          0    19611    hdb_permission 
   TABLE DATA               �   COPY hdb_catalog.hdb_permission (table_schema, table_name, role_name, perm_type, perm_def, comment, is_system_defined) FROM stdin;
    hdb_catalog       postgres    false    264   #�      `          0    19747    hdb_query_collection 
   TABLE DATA               q   COPY hdb_catalog.hdb_query_collection (collection_name, collection_defn, comment, is_system_defined) FROM stdin;
    hdb_catalog       postgres    false    280   @�      W          0    19596    hdb_relationship 
   TABLE DATA               �   COPY hdb_catalog.hdb_relationship (table_schema, table_name, rel_name, rel_type, rel_def, comment, is_system_defined) FROM stdin;
    hdb_catalog       postgres    false    263   ]�      _          0    19726    hdb_schema_update_event 
   TABLE DATA               _   COPY hdb_catalog.hdb_schema_update_event (instance_id, occurred_at, invalidations) FROM stdin;
    hdb_catalog       postgres    false    277   \�      V          0    19586 	   hdb_table 
   TABLE DATA               m   COPY hdb_catalog.hdb_table (table_schema, table_name, configuration, is_system_defined, is_enum) FROM stdin;
    hdb_catalog       postgres    false    262   ��      U          0    19574    hdb_version 
   TABLE DATA               g   COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
    hdb_catalog       postgres    false    261   2�      ^          0    19715    remote_schemas 
   TABLE DATA               L   COPY hdb_catalog.remote_schemas (id, name, definition, comment) FROM stdin;
    hdb_catalog       postgres    false    276   ��                0    18773 
   auth_group 
   TABLE DATA               .   COPY public.auth_group (id, name) FROM stdin;
    public       postgres    false    206   ��                 0    18783    auth_group_permissions 
   TABLE DATA               M   COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
    public       postgres    false    208   �                0    18765    auth_permission 
   TABLE DATA               N   COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
    public       postgres    false    204   c�      "          0    18791 	   auth_user 
   TABLE DATA               �   COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
    public       postgres    false    210   ��      $          0    18801    auth_user_groups 
   TABLE DATA               A   COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
    public       postgres    false    212   ��      &          0    18809    auth_user_user_permissions 
   TABLE DATA               P   COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
    public       postgres    false    214   p�      )          0    18900    authtoken_token 
   TABLE DATA               @   COPY public.authtoken_token (key, created, user_id) FROM stdin;
    public       postgres    false    217   ��      d          0    19790    controle_atendimento_chat 
   TABLE DATA               b   COPY public.controle_atendimento_chat (id, active, date, citizen_id, professional_id) FROM stdin;
    public       postgres    false    285   �      j          0    19818    controle_atendimento_message 
   TABLE DATA               �   COPY public.controle_atendimento_message (id, date, date_last_modification, message, file, received, is_professional, chat_id) FROM stdin;
    public       postgres    false    291   9�      h          0    19808    controle_atendimento_patient 
   TABLE DATA               {   COPY public.controle_atendimento_patient (id, date, date_last_modification, cpf, sus_code, status, citizen_id) FROM stdin;
    public       postgres    false    289   V�      f          0    19798    controle_atendimento_prontuario 
   TABLE DATA               x   COPY public.controle_atendimento_prontuario (id, date, date_last_modification, citizen_id, professional_id) FROM stdin;
    public       postgres    false    287   s�      +          0    18920    core_analisy 
   TABLE DATA               �   COPY public.core_analisy (id, date, has_faver, fever, citizen_id, "covidContact_id", "latLng_id", patient_situation, teleatend_status, "otherSympton") FROM stdin;
    public       postgres    false    219   ��      O          0    19108    core_analisy_listSympton 
   TABLE DATA               P   COPY public."core_analisy_listSympton" (id, analisy_id, sympton_id) FROM stdin;
    public       postgres    false    255   	�      l          0    20978    core_appversion 
   TABLE DATA               M   COPY public.core_appversion (id, version, active, "fileVersion") FROM stdin;
    public       postgres    false    293   ��      T          0    19477    core_blogpost 
   TABLE DATA               \   COPY public.core_blogpost (id, "postDate", title, body, photo, active, city_id) FROM stdin;
    public       postgres    false    260   �      -          0    18928    core_categorysympton 
   TABLE DATA               E   COPY public.core_categorysympton (id, name, description) FROM stdin;
    public       postgres    false    221   ��      K          0    19072    core_citizen 
   TABLE DATA               �   COPY public.core_citizen (id, "otherRiskGroup", name, "phoneNumber", cep, city_id, "userProfile_id", age, sex, neighborhood, street, street_number, "healthCenter_id") FROM stdin;
    public       postgres    false    251   Q�      M          0    19085    core_citizen_listRiskGroup 
   TABLE DATA               T   COPY public."core_citizen_listRiskGroup" (id, citizen_id, riskgroup_id) FROM stdin;
    public       postgres    false    253   �      /          0    18939 	   core_city 
   TABLE DATA               B   COPY public.core_city (id, name, "latLng_id", active) FROM stdin;
    public       postgres    false    223   �      1          0    18947    core_covidcontact 
   TABLE DATA               W   COPY public.core_covidcontact (id, description, active, "typeContactCode") FROM stdin;
    public       postgres    false    225   �      I          0    19059    core_dailynewsletter 
   TABLE DATA               �   COPY public.core_dailynewsletter (id, date, "underInvestigation", waiting_exam, confirmed, recovered, deaths, city_id, discarded, date_publication, active) FROM stdin;
    public       postgres    false    249   x      3          0    18955    core_disease 
   TABLE DATA               =   COPY public.core_disease (id, name, description) FROM stdin;
    public       postgres    false    227         G          0    19051    core_disease_listSympton 
   TABLE DATA               P   COPY public."core_disease_listSympton" (id, disease_id, sympton_id) FROM stdin;
    public       postgres    false    247   7      C          0    19032    core_healthcenter 
   TABLE DATA               �   COPY public.core_healthcenter (id, name, street, street_number, neighborhood, phone_number, city_id, "latLng_id", coverage, active) FROM stdin;
    public       postgres    false    243   T      E          0    19043 "   core_healthcenter_listProfessional 
   TABLE DATA               d   COPY public."core_healthcenter_listProfessional" (id, healthcenter_id, professional_id) FROM stdin;
    public       postgres    false    245   �      Q          0    19335    core_healthtips 
   TABLE DATA               R   COPY public.core_healthtips (id, title, body, photo, active, city_id) FROM stdin;
    public       postgres    false    257   �      5          0    18966    core_latlng 
   TABLE DATA               3   COPY public.core_latlng (id, lat, lng) FROM stdin;
    public       postgres    false    229   �      n          0    21299    core_partner 
   TABLE DATA               U   COPY public.core_partner (id, name, email, "phoneNumber", resume, photo) FROM stdin;
    public       postgres    false    295   ~      A          0    19022    core_professional 
   TABLE DATA               �   COPY public.core_professional (id, name, "typeProfessional_id", user_id, email, "firstAccess", "phoneNumber", active, city_id) FROM stdin;
    public       postgres    false    241   �      ?          0    19014    core_riskanalisy 
   TABLE DATA               F   COPY public.core_riskanalisy (id, analisy_id, disease_id) FROM stdin;
    public       postgres    false    239   ,      7          0    18977    core_riskgroup 
   TABLE DATA               2   COPY public.core_riskgroup (id, name) FROM stdin;
    public       postgres    false    231   I      =          0    19003    core_sympton 
   TABLE DATA               J   COPY public.core_sympton (id, name, description, category_id) FROM stdin;
    public       postgres    false    237   �      r          0    21331 	   core_team 
   TABLE DATA               '   COPY public.core_team (id) FROM stdin;
    public       postgres    false    299   �      t          0    21339    core_team_partners 
   TABLE DATA               E   COPY public.core_team_partners (id, team_id, partner_id) FROM stdin;
    public       postgres    false    301   �      v          0    21347    core_team_teamMembers 
   TABLE DATA               M   COPY public."core_team_teamMembers" (id, team_id, teammember_id) FROM stdin;
    public       postgres    false    303         p          0    21310    core_teammember 
   TABLE DATA               X   COPY public.core_teammember (id, name, email, "phoneNumber", resume, photo) FROM stdin;
    public       postgres    false    297   $      9          0    18985    core_typeprofessional 
   TABLE DATA               ]   COPY public.core_typeprofessional (id, name, "codeDocumentType", "userGroup_id") FROM stdin;
    public       postgres    false    233   A      ;          0    18993    core_userprofile 
   TABLE DATA               @   COPY public.core_userprofile (id, city_id, user_id) FROM stdin;
    public       postgres    false    235   {      (          0    18869    django_admin_log 
   TABLE DATA               �   COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
    public       postgres    false    216   �                0    18755    django_content_type 
   TABLE DATA               C   COPY public.django_content_type (id, app_label, model) FROM stdin;
    public       postgres    false    202   �2                0    18744    django_migrations 
   TABLE DATA               C   COPY public.django_migrations (id, app, name, applied) FROM stdin;
    public       postgres    false    200   14      R          0    19344    django_session 
   TABLE DATA               P   COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
    public       postgres    false    258   p:      �           0    0    remote_schemas_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('hdb_catalog.remote_schemas_id_seq', 1, false);
            hdb_catalog       postgres    false    275            �           0    0    auth_group_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.auth_group_id_seq', 3, true);
            public       postgres    false    205            �           0    0    auth_group_permissions_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 153, true);
            public       postgres    false    207            �           0    0    auth_permission_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.auth_permission_id_seq', 146, true);
            public       postgres    false    203            �           0    0    auth_user_groups_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 66, true);
            public       postgres    false    211            �           0    0    auth_user_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.auth_user_id_seq', 31, true);
            public       postgres    false    209            �           0    0 !   auth_user_user_permissions_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 144, true);
            public       postgres    false    213            �           0    0     controle_atendimento_chat_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.controle_atendimento_chat_id_seq', 1, false);
            public       postgres    false    284            �           0    0 #   controle_atendimento_message_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.controle_atendimento_message_id_seq', 1, false);
            public       postgres    false    290            �           0    0 #   controle_atendimento_patient_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.controle_atendimento_patient_id_seq', 1, false);
            public       postgres    false    288            �           0    0 &   controle_atendimento_prontuario_id_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.controle_atendimento_prontuario_id_seq', 1, false);
            public       postgres    false    286            �           0    0    core_analisy_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.core_analisy_id_seq', 124, true);
            public       postgres    false    218            �           0    0    core_analisy_listSympton_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public."core_analisy_listSympton_id_seq"', 248, true);
            public       postgres    false    254            �           0    0    core_appversion_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.core_appversion_id_seq', 1, false);
            public       postgres    false    292            �           0    0    core_blogpost_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.core_blogpost_id_seq', 10, true);
            public       postgres    false    259            �           0    0    core_categorysympton_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.core_categorysympton_id_seq', 4, true);
            public       postgres    false    220            �           0    0    core_citizen_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.core_citizen_id_seq', 128, true);
            public       postgres    false    250            �           0    0 !   core_citizen_listRiskGroup_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public."core_citizen_listRiskGroup_id_seq"', 105, true);
            public       postgres    false    252            �           0    0    core_city_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.core_city_id_seq', 1, true);
            public       postgres    false    222            �           0    0    core_covidcontact_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.core_covidcontact_id_seq', 3, true);
            public       postgres    false    224            �           0    0    core_dailynewsletter_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.core_dailynewsletter_id_seq', 24, true);
            public       postgres    false    248            �           0    0    core_disease_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.core_disease_id_seq', 1, false);
            public       postgres    false    226            �           0    0    core_disease_listSympton_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public."core_disease_listSympton_id_seq"', 1, false);
            public       postgres    false    246            �           0    0    core_healthcenter_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.core_healthcenter_id_seq', 29, true);
            public       postgres    false    242            �           0    0 )   core_healthcenter_listProfessional_id_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public."core_healthcenter_listProfessional_id_seq"', 35, true);
            public       postgres    false    244            �           0    0    core_healthtips_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.core_healthtips_id_seq', 10, true);
            public       postgres    false    256            �           0    0    core_latlng_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.core_latlng_id_seq', 121, true);
            public       postgres    false    228            �           0    0    core_partner_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.core_partner_id_seq', 1, false);
            public       postgres    false    294            �           0    0    core_professional_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.core_professional_id_seq', 28, true);
            public       postgres    false    240            �           0    0    core_riskanalisy_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.core_riskanalisy_id_seq', 1, false);
            public       postgres    false    238            �           0    0    core_riskgroup_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.core_riskgroup_id_seq', 11, true);
            public       postgres    false    230            �           0    0    core_sympton_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.core_sympton_id_seq', 12, true);
            public       postgres    false    236            �           0    0    core_team_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.core_team_id_seq', 1, false);
            public       postgres    false    298            �           0    0    core_team_partners_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.core_team_partners_id_seq', 1, false);
            public       postgres    false    300            �           0    0    core_team_teamMembers_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public."core_team_teamMembers_id_seq"', 1, false);
            public       postgres    false    302            �           0    0    core_teammember_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.core_teammember_id_seq', 1, false);
            public       postgres    false    296            �           0    0    core_typeprofessional_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.core_typeprofessional_id_seq', 3, true);
            public       postgres    false    232            �           0    0    core_userprofile_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.core_userprofile_id_seq', 2, true);
            public       postgres    false    234            �           0    0    django_admin_log_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.django_admin_log_id_seq', 382, true);
            public       postgres    false    215            �           0    0    django_content_type_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.django_content_type_id_seq', 33, true);
            public       postgres    false    201            �           0    0    django_migrations_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.django_migrations_id_seq', 82, true);
            public       postgres    false    199            +           2606    19691 0   event_invocation_logs event_invocation_logs_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_pkey PRIMARY KEY (id);
 _   ALTER TABLE ONLY hdb_catalog.event_invocation_logs DROP CONSTRAINT event_invocation_logs_pkey;
       hdb_catalog         postgres    false    272            '           2606    19678    event_log event_log_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY hdb_catalog.event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY hdb_catalog.event_log DROP CONSTRAINT event_log_pkey;
       hdb_catalog         postgres    false    271            #           2606    19658 "   event_triggers event_triggers_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_pkey PRIMARY KEY (name);
 Q   ALTER TABLE ONLY hdb_catalog.event_triggers DROP CONSTRAINT event_triggers_pkey;
       hdb_catalog         postgres    false    270            6           2606    19763 /   hdb_allowlist hdb_allowlist_collection_name_key 
   CONSTRAINT     z   ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_key UNIQUE (collection_name);
 ^   ALTER TABLE ONLY hdb_catalog.hdb_allowlist DROP CONSTRAINT hdb_allowlist_collection_name_key;
       hdb_catalog         postgres    false    281            8           2606    19776 *   hdb_computed_field hdb_computed_field_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.hdb_computed_field
    ADD CONSTRAINT hdb_computed_field_pkey PRIMARY KEY (table_schema, table_name, computed_field_name);
 Y   ALTER TABLE ONLY hdb_catalog.hdb_computed_field DROP CONSTRAINT hdb_computed_field_pkey;
       hdb_catalog         postgres    false    282    282    282            -           2606    19707    hdb_function hdb_function_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY hdb_catalog.hdb_function
    ADD CONSTRAINT hdb_function_pkey PRIMARY KEY (function_schema, function_name);
 M   ALTER TABLE ONLY hdb_catalog.hdb_function DROP CONSTRAINT hdb_function_pkey;
       hdb_catalog         postgres    false    273    273            !           2606    19620 "   hdb_permission hdb_permission_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_pkey PRIMARY KEY (table_schema, table_name, role_name, perm_type);
 Q   ALTER TABLE ONLY hdb_catalog.hdb_permission DROP CONSTRAINT hdb_permission_pkey;
       hdb_catalog         postgres    false    264    264    264    264            4           2606    19755 .   hdb_query_collection hdb_query_collection_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY hdb_catalog.hdb_query_collection
    ADD CONSTRAINT hdb_query_collection_pkey PRIMARY KEY (collection_name);
 ]   ALTER TABLE ONLY hdb_catalog.hdb_query_collection DROP CONSTRAINT hdb_query_collection_pkey;
       hdb_catalog         postgres    false    280                       2606    19605 &   hdb_relationship hdb_relationship_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_pkey PRIMARY KEY (table_schema, table_name, rel_name);
 U   ALTER TABLE ONLY hdb_catalog.hdb_relationship DROP CONSTRAINT hdb_relationship_pkey;
       hdb_catalog         postgres    false    263    263    263                       2606    19595    hdb_table hdb_table_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY hdb_catalog.hdb_table
    ADD CONSTRAINT hdb_table_pkey PRIMARY KEY (table_schema, table_name);
 G   ALTER TABLE ONLY hdb_catalog.hdb_table DROP CONSTRAINT hdb_table_pkey;
       hdb_catalog         postgres    false    262    262                       2606    19584    hdb_version hdb_version_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);
 K   ALTER TABLE ONLY hdb_catalog.hdb_version DROP CONSTRAINT hdb_version_pkey;
       hdb_catalog         postgres    false    261            /           2606    19725 &   remote_schemas remote_schemas_name_key 
   CONSTRAINT     f   ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_name_key UNIQUE (name);
 U   ALTER TABLE ONLY hdb_catalog.remote_schemas DROP CONSTRAINT remote_schemas_name_key;
       hdb_catalog         postgres    false    276            1           2606    19723 "   remote_schemas remote_schemas_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY hdb_catalog.remote_schemas DROP CONSTRAINT remote_schemas_pkey;
       hdb_catalog         postgres    false    276            �           2606    18898    auth_group auth_group_name_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);
 H   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_name_key;
       public         postgres    false    206            �           2606    18825 R   auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);
 |   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq;
       public         postgres    false    208    208            �           2606    18788 2   auth_group_permissions auth_group_permissions_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_pkey;
       public         postgres    false    208            �           2606    18778    auth_group auth_group_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_pkey;
       public         postgres    false    206            �           2606    18816 F   auth_permission auth_permission_content_type_id_codename_01ab375a_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);
 p   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq;
       public         postgres    false    204    204            �           2606    18770 $   auth_permission auth_permission_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_pkey;
       public         postgres    false    204            �           2606    18806 &   auth_user_groups auth_user_groups_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_pkey;
       public         postgres    false    212            �           2606    18840 @   auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);
 j   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq;
       public         postgres    false    212    212            �           2606    18796    auth_user auth_user_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.auth_user DROP CONSTRAINT auth_user_pkey;
       public         postgres    false    210            �           2606    18814 :   auth_user_user_permissions auth_user_user_permissions_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permissions_pkey;
       public         postgres    false    214            �           2606    18854 Y   auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);
 �   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq;
       public         postgres    false    214    214            �           2606    18892     auth_user auth_user_username_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);
 J   ALTER TABLE ONLY public.auth_user DROP CONSTRAINT auth_user_username_key;
       public         postgres    false    210            �           2606    18904 $   authtoken_token authtoken_token_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.authtoken_token
    ADD CONSTRAINT authtoken_token_pkey PRIMARY KEY (key);
 N   ALTER TABLE ONLY public.authtoken_token DROP CONSTRAINT authtoken_token_pkey;
       public         postgres    false    217            �           2606    18906 +   authtoken_token authtoken_token_user_id_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.authtoken_token
    ADD CONSTRAINT authtoken_token_user_id_key UNIQUE (user_id);
 U   ALTER TABLE ONLY public.authtoken_token DROP CONSTRAINT authtoken_token_user_id_key;
       public         postgres    false    217            ;           2606    19795 8   controle_atendimento_chat controle_atendimento_chat_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.controle_atendimento_chat
    ADD CONSTRAINT controle_atendimento_chat_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.controle_atendimento_chat DROP CONSTRAINT controle_atendimento_chat_pkey;
       public         postgres    false    285            H           2606    19826 >   controle_atendimento_message controle_atendimento_message_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.controle_atendimento_message
    ADD CONSTRAINT controle_atendimento_message_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.controle_atendimento_message DROP CONSTRAINT controle_atendimento_message_pkey;
       public         postgres    false    291            C           2606    19815 H   controle_atendimento_patient controle_atendimento_patient_citizen_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_patient
    ADD CONSTRAINT controle_atendimento_patient_citizen_id_key UNIQUE (citizen_id);
 r   ALTER TABLE ONLY public.controle_atendimento_patient DROP CONSTRAINT controle_atendimento_patient_citizen_id_key;
       public         postgres    false    289            E           2606    19813 >   controle_atendimento_patient controle_atendimento_patient_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.controle_atendimento_patient
    ADD CONSTRAINT controle_atendimento_patient_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.controle_atendimento_patient DROP CONSTRAINT controle_atendimento_patient_pkey;
       public         postgres    false    289            >           2606    19805 N   controle_atendimento_prontuario controle_atendimento_prontuario_citizen_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_prontuario
    ADD CONSTRAINT controle_atendimento_prontuario_citizen_id_key UNIQUE (citizen_id);
 x   ALTER TABLE ONLY public.controle_atendimento_prontuario DROP CONSTRAINT controle_atendimento_prontuario_citizen_id_key;
       public         postgres    false    287            @           2606    19803 D   controle_atendimento_prontuario controle_atendimento_prontuario_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_prontuario
    ADD CONSTRAINT controle_atendimento_prontuario_pkey PRIMARY KEY (id);
 n   ALTER TABLE ONLY public.controle_atendimento_prontuario DROP CONSTRAINT controle_atendimento_prontuario_pkey;
       public         postgres    false    287                       2606    19230 U   core_analisy_listSympton core_analisy_listSympton_analisy_id_sympton_id_a0c64758_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public."core_analisy_listSympton"
    ADD CONSTRAINT "core_analisy_listSympton_analisy_id_sympton_id_a0c64758_uniq" UNIQUE (analisy_id, sympton_id);
 �   ALTER TABLE ONLY public."core_analisy_listSympton" DROP CONSTRAINT "core_analisy_listSympton_analisy_id_sympton_id_a0c64758_uniq";
       public         postgres    false    255    255                       2606    19113 6   core_analisy_listSympton core_analisy_listSympton_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public."core_analisy_listSympton"
    ADD CONSTRAINT "core_analisy_listSympton_pkey" PRIMARY KEY (id);
 d   ALTER TABLE ONLY public."core_analisy_listSympton" DROP CONSTRAINT "core_analisy_listSympton_pkey";
       public         postgres    false    255            �           2606    18925    core_analisy core_analisy_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.core_analisy
    ADD CONSTRAINT core_analisy_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.core_analisy DROP CONSTRAINT core_analisy_pkey;
       public         postgres    false    219            J           2606    20983 $   core_appversion core_appversion_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.core_appversion
    ADD CONSTRAINT core_appversion_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.core_appversion DROP CONSTRAINT core_appversion_pkey;
       public         postgres    false    293                       2606    19485     core_blogpost core_blogpost_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.core_blogpost
    ADD CONSTRAINT core_blogpost_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.core_blogpost DROP CONSTRAINT core_blogpost_pkey;
       public         postgres    false    260            �           2606    18936 .   core_categorysympton core_categorysympton_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.core_categorysympton
    ADD CONSTRAINT core_categorysympton_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.core_categorysympton DROP CONSTRAINT core_categorysympton_pkey;
       public         postgres    false    221                       2606    19213 Y   core_citizen_listRiskGroup core_citizen_listRiskGro_citizen_id_riskgroup_id_1c307ee6_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public."core_citizen_listRiskGroup"
    ADD CONSTRAINT "core_citizen_listRiskGro_citizen_id_riskgroup_id_1c307ee6_uniq" UNIQUE (citizen_id, riskgroup_id);
 �   ALTER TABLE ONLY public."core_citizen_listRiskGroup" DROP CONSTRAINT "core_citizen_listRiskGro_citizen_id_riskgroup_id_1c307ee6_uniq";
       public         postgres    false    253    253                       2606    19090 :   core_citizen_listRiskGroup core_citizen_listRiskGroup_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public."core_citizen_listRiskGroup"
    ADD CONSTRAINT "core_citizen_listRiskGroup_pkey" PRIMARY KEY (id);
 h   ALTER TABLE ONLY public."core_citizen_listRiskGroup" DROP CONSTRAINT "core_citizen_listRiskGroup_pkey";
       public         postgres    false    253                        2606    19080    core_citizen core_citizen_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.core_citizen
    ADD CONSTRAINT core_citizen_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.core_citizen DROP CONSTRAINT core_citizen_pkey;
       public         postgres    false    251                       2606    19082 ,   core_citizen core_citizen_userProfile_id_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.core_citizen
    ADD CONSTRAINT "core_citizen_userProfile_id_key" UNIQUE ("userProfile_id");
 X   ALTER TABLE ONLY public.core_citizen DROP CONSTRAINT "core_citizen_userProfile_id_key";
       public         postgres    false    251            �           2606    18944    core_city core_city_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.core_city
    ADD CONSTRAINT core_city_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.core_city DROP CONSTRAINT core_city_pkey;
       public         postgres    false    223            �           2606    18952 (   core_covidcontact core_covidcontact_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.core_covidcontact
    ADD CONSTRAINT core_covidcontact_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.core_covidcontact DROP CONSTRAINT core_covidcontact_pkey;
       public         postgres    false    225            �           2606    19064 .   core_dailynewsletter core_dailynewsletter_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.core_dailynewsletter
    ADD CONSTRAINT core_dailynewsletter_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.core_dailynewsletter DROP CONSTRAINT core_dailynewsletter_pkey;
       public         postgres    false    249            �           2606    19181 U   core_disease_listSympton core_disease_listSympton_disease_id_sympton_id_aba74b11_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public."core_disease_listSympton"
    ADD CONSTRAINT "core_disease_listSympton_disease_id_sympton_id_aba74b11_uniq" UNIQUE (disease_id, sympton_id);
 �   ALTER TABLE ONLY public."core_disease_listSympton" DROP CONSTRAINT "core_disease_listSympton_disease_id_sympton_id_aba74b11_uniq";
       public         postgres    false    247    247            �           2606    19056 6   core_disease_listSympton core_disease_listSympton_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public."core_disease_listSympton"
    ADD CONSTRAINT "core_disease_listSympton_pkey" PRIMARY KEY (id);
 d   ALTER TABLE ONLY public."core_disease_listSympton" DROP CONSTRAINT "core_disease_listSympton_pkey";
       public         postgres    false    247            �           2606    18963    core_disease core_disease_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.core_disease
    ADD CONSTRAINT core_disease_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.core_disease DROP CONSTRAINT core_disease_pkey;
       public         postgres    false    227            �           2606    19167 b   core_healthcenter_listProfessional core_healthcenter_listPr_healthcenter_id_professi_66d0561b_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public."core_healthcenter_listProfessional"
    ADD CONSTRAINT "core_healthcenter_listPr_healthcenter_id_professi_66d0561b_uniq" UNIQUE (healthcenter_id, professional_id);
 �   ALTER TABLE ONLY public."core_healthcenter_listProfessional" DROP CONSTRAINT "core_healthcenter_listPr_healthcenter_id_professi_66d0561b_uniq";
       public         postgres    false    245    245            �           2606    19048 J   core_healthcenter_listProfessional core_healthcenter_listProfessional_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."core_healthcenter_listProfessional"
    ADD CONSTRAINT "core_healthcenter_listProfessional_pkey" PRIMARY KEY (id);
 x   ALTER TABLE ONLY public."core_healthcenter_listProfessional" DROP CONSTRAINT "core_healthcenter_listProfessional_pkey";
       public         postgres    false    245            �           2606    19040 (   core_healthcenter core_healthcenter_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.core_healthcenter
    ADD CONSTRAINT core_healthcenter_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.core_healthcenter DROP CONSTRAINT core_healthcenter_pkey;
       public         postgres    false    243                       2606    19343 $   core_healthtips core_healthtips_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.core_healthtips
    ADD CONSTRAINT core_healthtips_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.core_healthtips DROP CONSTRAINT core_healthtips_pkey;
       public         postgres    false    257            �           2606    18974    core_latlng core_latlng_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.core_latlng
    ADD CONSTRAINT core_latlng_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.core_latlng DROP CONSTRAINT core_latlng_pkey;
       public         postgres    false    229            L           2606    21307    core_partner core_partner_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.core_partner
    ADD CONSTRAINT core_partner_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.core_partner DROP CONSTRAINT core_partner_pkey;
       public         postgres    false    295            �           2606    19027 (   core_professional core_professional_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.core_professional
    ADD CONSTRAINT core_professional_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.core_professional DROP CONSTRAINT core_professional_pkey;
       public         postgres    false    241            �           2606    19245 /   core_professional core_professional_user_id_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.core_professional
    ADD CONSTRAINT core_professional_user_id_key UNIQUE (user_id);
 Y   ALTER TABLE ONLY public.core_professional DROP CONSTRAINT core_professional_user_id_key;
       public         postgres    false    241            �           2606    19019 &   core_riskanalisy core_riskanalisy_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.core_riskanalisy
    ADD CONSTRAINT core_riskanalisy_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.core_riskanalisy DROP CONSTRAINT core_riskanalisy_pkey;
       public         postgres    false    239            �           2606    18982 "   core_riskgroup core_riskgroup_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.core_riskgroup
    ADD CONSTRAINT core_riskgroup_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.core_riskgroup DROP CONSTRAINT core_riskgroup_pkey;
       public         postgres    false    231            �           2606    19011    core_sympton core_sympton_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.core_sympton
    ADD CONSTRAINT core_sympton_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.core_sympton DROP CONSTRAINT core_sympton_pkey;
       public         postgres    false    237            S           2606    21344 *   core_team_partners core_team_partners_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.core_team_partners
    ADD CONSTRAINT core_team_partners_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.core_team_partners DROP CONSTRAINT core_team_partners_pkey;
       public         postgres    false    301            V           2606    21356 F   core_team_partners core_team_partners_team_id_partner_id_950a9681_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.core_team_partners
    ADD CONSTRAINT core_team_partners_team_id_partner_id_950a9681_uniq UNIQUE (team_id, partner_id);
 p   ALTER TABLE ONLY public.core_team_partners DROP CONSTRAINT core_team_partners_team_id_partner_id_950a9681_uniq;
       public         postgres    false    301    301            P           2606    21336    core_team core_team_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.core_team
    ADD CONSTRAINT core_team_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.core_team DROP CONSTRAINT core_team_pkey;
       public         postgres    false    299            X           2606    21352 0   core_team_teamMembers core_team_teamMembers_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public."core_team_teamMembers"
    ADD CONSTRAINT "core_team_teamMembers_pkey" PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public."core_team_teamMembers" DROP CONSTRAINT "core_team_teamMembers_pkey";
       public         postgres    false    303            [           2606    21370 O   core_team_teamMembers core_team_teamMembers_team_id_teammember_id_12b6cd55_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public."core_team_teamMembers"
    ADD CONSTRAINT "core_team_teamMembers_team_id_teammember_id_12b6cd55_uniq" UNIQUE (team_id, teammember_id);
 }   ALTER TABLE ONLY public."core_team_teamMembers" DROP CONSTRAINT "core_team_teamMembers_team_id_teammember_id_12b6cd55_uniq";
       public         postgres    false    303    303            N           2606    21318 $   core_teammember core_teammember_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.core_teammember
    ADD CONSTRAINT core_teammember_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.core_teammember DROP CONSTRAINT core_teammember_pkey;
       public         postgres    false    297            �           2606    18990 0   core_typeprofessional core_typeprofessional_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.core_typeprofessional
    ADD CONSTRAINT core_typeprofessional_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.core_typeprofessional DROP CONSTRAINT core_typeprofessional_pkey;
       public         postgres    false    233            �           2606    18998 &   core_userprofile core_userprofile_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.core_userprofile
    ADD CONSTRAINT core_userprofile_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.core_userprofile DROP CONSTRAINT core_userprofile_pkey;
       public         postgres    false    235            �           2606    19000 -   core_userprofile core_userprofile_user_id_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.core_userprofile
    ADD CONSTRAINT core_userprofile_user_id_key UNIQUE (user_id);
 W   ALTER TABLE ONLY public.core_userprofile DROP CONSTRAINT core_userprofile_user_id_key;
       public         postgres    false    235            �           2606    18878 &   django_admin_log django_admin_log_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_pkey;
       public         postgres    false    216            �           2606    18762 E   django_content_type django_content_type_app_label_model_76bd3d3b_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);
 o   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq;
       public         postgres    false    202    202            �           2606    18760 ,   django_content_type django_content_type_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_pkey;
       public         postgres    false    202            �           2606    18752 (   django_migrations django_migrations_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.django_migrations DROP CONSTRAINT django_migrations_pkey;
       public         postgres    false    200                       2606    19351 "   django_session django_session_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);
 L   ALTER TABLE ONLY public.django_session DROP CONSTRAINT django_session_pkey;
       public         postgres    false    258            )           1259    19697 "   event_invocation_logs_event_id_idx    INDEX     m   CREATE INDEX event_invocation_logs_event_id_idx ON hdb_catalog.event_invocation_logs USING btree (event_id);
 ;   DROP INDEX hdb_catalog.event_invocation_logs_event_id_idx;
       hdb_catalog         postgres    false    272            $           1259    19681    event_log_delivered_idx    INDEX     W   CREATE INDEX event_log_delivered_idx ON hdb_catalog.event_log USING btree (delivered);
 0   DROP INDEX hdb_catalog.event_log_delivered_idx;
       hdb_catalog         postgres    false    271            %           1259    19680    event_log_locked_idx    INDEX     Q   CREATE INDEX event_log_locked_idx ON hdb_catalog.event_log USING btree (locked);
 -   DROP INDEX hdb_catalog.event_log_locked_idx;
       hdb_catalog         postgres    false    271            (           1259    19679    event_log_trigger_name_idx    INDEX     ]   CREATE INDEX event_log_trigger_name_idx ON hdb_catalog.event_log USING btree (trigger_name);
 3   DROP INDEX hdb_catalog.event_log_trigger_name_idx;
       hdb_catalog         postgres    false    271            2           1259    19733    hdb_schema_update_event_one_row    INDEX     �   CREATE UNIQUE INDEX hdb_schema_update_event_one_row ON hdb_catalog.hdb_schema_update_event USING btree (((occurred_at IS NOT NULL)));
 8   DROP INDEX hdb_catalog.hdb_schema_update_event_one_row;
       hdb_catalog         postgres    false    277    277                       1259    19585    hdb_version_one_row    INDEX     j   CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));
 ,   DROP INDEX hdb_catalog.hdb_version_one_row;
       hdb_catalog         postgres    false    261    261            �           1259    18899    auth_group_name_a6ea08ec_like    INDEX     h   CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);
 1   DROP INDEX public.auth_group_name_a6ea08ec_like;
       public         postgres    false    206            �           1259    18836 (   auth_group_permissions_group_id_b120cbf9    INDEX     o   CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);
 <   DROP INDEX public.auth_group_permissions_group_id_b120cbf9;
       public         postgres    false    208            �           1259    18837 -   auth_group_permissions_permission_id_84c5c92e    INDEX     y   CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);
 A   DROP INDEX public.auth_group_permissions_permission_id_84c5c92e;
       public         postgres    false    208            �           1259    18822 (   auth_permission_content_type_id_2f476e4b    INDEX     o   CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);
 <   DROP INDEX public.auth_permission_content_type_id_2f476e4b;
       public         postgres    false    204            �           1259    18852 "   auth_user_groups_group_id_97559544    INDEX     c   CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);
 6   DROP INDEX public.auth_user_groups_group_id_97559544;
       public         postgres    false    212            �           1259    18851 !   auth_user_groups_user_id_6a12ed8b    INDEX     a   CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);
 5   DROP INDEX public.auth_user_groups_user_id_6a12ed8b;
       public         postgres    false    212            �           1259    18866 1   auth_user_user_permissions_permission_id_1fbb5f2c    INDEX     �   CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);
 E   DROP INDEX public.auth_user_user_permissions_permission_id_1fbb5f2c;
       public         postgres    false    214            �           1259    18865 +   auth_user_user_permissions_user_id_a95ead1b    INDEX     u   CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);
 ?   DROP INDEX public.auth_user_user_permissions_user_id_a95ead1b;
       public         postgres    false    214            �           1259    18893     auth_user_username_6821ab7c_like    INDEX     n   CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);
 4   DROP INDEX public.auth_user_username_6821ab7c_like;
       public         postgres    false    210            �           1259    18912 !   authtoken_token_key_10f0b77e_like    INDEX     p   CREATE INDEX authtoken_token_key_10f0b77e_like ON public.authtoken_token USING btree (key varchar_pattern_ops);
 5   DROP INDEX public.authtoken_token_key_10f0b77e_like;
       public         postgres    false    217            9           1259    19837 -   controle_atendimento_chat_citizen_id_8189d62b    INDEX     y   CREATE INDEX controle_atendimento_chat_citizen_id_8189d62b ON public.controle_atendimento_chat USING btree (citizen_id);
 A   DROP INDEX public.controle_atendimento_chat_citizen_id_8189d62b;
       public         postgres    false    285            <           1259    19838 2   controle_atendimento_chat_professional_id_685743fe    INDEX     �   CREATE INDEX controle_atendimento_chat_professional_id_685743fe ON public.controle_atendimento_chat USING btree (professional_id);
 F   DROP INDEX public.controle_atendimento_chat_professional_id_685743fe;
       public         postgres    false    285            F           1259    19860 -   controle_atendimento_message_chat_id_59ad1b4b    INDEX     y   CREATE INDEX controle_atendimento_message_chat_id_59ad1b4b ON public.controle_atendimento_message USING btree (chat_id);
 A   DROP INDEX public.controle_atendimento_message_chat_id_59ad1b4b;
       public         postgres    false    291            A           1259    19849 8   controle_atendimento_prontuario_professional_id_acc49a11    INDEX     �   CREATE INDEX controle_atendimento_prontuario_professional_id_acc49a11 ON public.controle_atendimento_prontuario USING btree (professional_id);
 L   DROP INDEX public.controle_atendimento_prontuario_professional_id_acc49a11;
       public         postgres    false    287            �           1259    19226     core_analisy_citizen_id_126782de    INDEX     _   CREATE INDEX core_analisy_citizen_id_126782de ON public.core_analisy USING btree (citizen_id);
 4   DROP INDEX public.core_analisy_citizen_id_126782de;
       public         postgres    false    219            �           1259    19227 %   core_analisy_covidContact_id_d772dfbe    INDEX     m   CREATE INDEX "core_analisy_covidContact_id_d772dfbe" ON public.core_analisy USING btree ("covidContact_id");
 ;   DROP INDEX public."core_analisy_covidContact_id_d772dfbe";
       public         postgres    false    219            �           1259    19228    core_analisy_latLng_id_589e14c1    INDEX     a   CREATE INDEX "core_analisy_latLng_id_589e14c1" ON public.core_analisy USING btree ("latLng_id");
 5   DROP INDEX public."core_analisy_latLng_id_589e14c1";
       public         postgres    false    219            	           1259    19241 ,   core_analisy_listSympton_analisy_id_d8925359    INDEX     {   CREATE INDEX "core_analisy_listSympton_analisy_id_d8925359" ON public."core_analisy_listSympton" USING btree (analisy_id);
 B   DROP INDEX public."core_analisy_listSympton_analisy_id_d8925359";
       public         postgres    false    255                       1259    19242 ,   core_analisy_listSympton_sympton_id_3856137a    INDEX     {   CREATE INDEX "core_analisy_listSympton_sympton_id_3856137a" ON public."core_analisy_listSympton" USING btree (sympton_id);
 B   DROP INDEX public."core_analisy_listSympton_sympton_id_3856137a";
       public         postgres    false    255                       1259    21353    core_blogpost_city_id_096f50d3    INDEX     [   CREATE INDEX core_blogpost_city_id_096f50d3 ON public.core_blogpost USING btree (city_id);
 2   DROP INDEX public.core_blogpost_city_id_096f50d3;
       public         postgres    false    260            �           1259    19211    core_citizen_city_id_2cdb6ae3    INDEX     Y   CREATE INDEX core_citizen_city_id_2cdb6ae3 ON public.core_citizen USING btree (city_id);
 1   DROP INDEX public.core_citizen_city_id_2cdb6ae3;
       public         postgres    false    251            �           1259    20927 %   core_citizen_healthCenter_id_1f0a751f    INDEX     m   CREATE INDEX "core_citizen_healthCenter_id_1f0a751f" ON public.core_citizen USING btree ("healthCenter_id");
 ;   DROP INDEX public."core_citizen_healthCenter_id_1f0a751f";
       public         postgres    false    251                       1259    19224 .   core_citizen_listRiskGroup_citizen_id_a827692c    INDEX        CREATE INDEX "core_citizen_listRiskGroup_citizen_id_a827692c" ON public."core_citizen_listRiskGroup" USING btree (citizen_id);
 D   DROP INDEX public."core_citizen_listRiskGroup_citizen_id_a827692c";
       public         postgres    false    253                       1259    19225 0   core_citizen_listRiskGroup_riskgroup_id_c63e0e2d    INDEX     �   CREATE INDEX "core_citizen_listRiskGroup_riskgroup_id_c63e0e2d" ON public."core_citizen_listRiskGroup" USING btree (riskgroup_id);
 F   DROP INDEX public."core_citizen_listRiskGroup_riskgroup_id_c63e0e2d";
       public         postgres    false    253            �           1259    19200    core_city_latLng_id_58b54250    INDEX     [   CREATE INDEX "core_city_latLng_id_58b54250" ON public.core_city USING btree ("latLng_id");
 2   DROP INDEX public."core_city_latLng_id_58b54250";
       public         postgres    false    223            �           1259    19199 %   core_dailynewsletter_city_id_df25d67e    INDEX     i   CREATE INDEX core_dailynewsletter_city_id_df25d67e ON public.core_dailynewsletter USING btree (city_id);
 9   DROP INDEX public.core_dailynewsletter_city_id_df25d67e;
       public         postgres    false    249            �           1259    19192 ,   core_disease_listSympton_disease_id_0c57eb03    INDEX     {   CREATE INDEX "core_disease_listSympton_disease_id_0c57eb03" ON public."core_disease_listSympton" USING btree (disease_id);
 B   DROP INDEX public."core_disease_listSympton_disease_id_0c57eb03";
       public         postgres    false    247            �           1259    19193 ,   core_disease_listSympton_sympton_id_24fd9948    INDEX     {   CREATE INDEX "core_disease_listSympton_sympton_id_24fd9948" ON public."core_disease_listSympton" USING btree (sympton_id);
 B   DROP INDEX public."core_disease_listSympton_sympton_id_24fd9948";
       public         postgres    false    247            �           1259    19922    core_health_neighbo_856382_idx    INDEX     d   CREATE INDEX core_health_neighbo_856382_idx ON public.core_healthcenter USING btree (neighborhood);
 2   DROP INDEX public.core_health_neighbo_856382_idx;
       public         postgres    false    243            �           1259    19164 "   core_healthcenter_city_id_09c6c9bf    INDEX     c   CREATE INDEX core_healthcenter_city_id_09c6c9bf ON public.core_healthcenter USING btree (city_id);
 6   DROP INDEX public.core_healthcenter_city_id_09c6c9bf;
       public         postgres    false    243            �           1259    19165 $   core_healthcenter_latLng_id_83cada46    INDEX     k   CREATE INDEX "core_healthcenter_latLng_id_83cada46" ON public.core_healthcenter USING btree ("latLng_id");
 :   DROP INDEX public."core_healthcenter_latLng_id_83cada46";
       public         postgres    false    243            �           1259    19178 ;   core_healthcenter_listProfessional_healthcenter_id_343ce92d    INDEX     �   CREATE INDEX "core_healthcenter_listProfessional_healthcenter_id_343ce92d" ON public."core_healthcenter_listProfessional" USING btree (healthcenter_id);
 Q   DROP INDEX public."core_healthcenter_listProfessional_healthcenter_id_343ce92d";
       public         postgres    false    245            �           1259    19179 ;   core_healthcenter_listProfessional_professional_id_054efaf8    INDEX     �   CREATE INDEX "core_healthcenter_listProfessional_professional_id_054efaf8" ON public."core_healthcenter_listProfessional" USING btree (professional_id);
 Q   DROP INDEX public."core_healthcenter_listProfessional_professional_id_054efaf8";
       public         postgres    false    245                       1259    21354     core_healthtips_city_id_7ec44a22    INDEX     _   CREATE INDEX core_healthtips_city_id_7ec44a22 ON public.core_healthtips USING btree (city_id);
 4   DROP INDEX public.core_healthtips_city_id_7ec44a22;
       public         postgres    false    257            �           1259    21286 "   core_professional_city_id_0b98d4b3    INDEX     c   CREATE INDEX core_professional_city_id_0b98d4b3 ON public.core_professional USING btree (city_id);
 6   DROP INDEX public.core_professional_city_id_0b98d4b3;
       public         postgres    false    241            �           1259    19153 .   core_professional_typeProfessional_id_430b6c93    INDEX        CREATE INDEX "core_professional_typeProfessional_id_430b6c93" ON public.core_professional USING btree ("typeProfessional_id");
 D   DROP INDEX public."core_professional_typeProfessional_id_430b6c93";
       public         postgres    false    241            �           1259    19141 $   core_riskanalisy_analisy_id_53e6770b    INDEX     g   CREATE INDEX core_riskanalisy_analisy_id_53e6770b ON public.core_riskanalisy USING btree (analisy_id);
 8   DROP INDEX public.core_riskanalisy_analisy_id_53e6770b;
       public         postgres    false    239            �           1259    19142 $   core_riskanalisy_disease_id_22ab5fb5    INDEX     g   CREATE INDEX core_riskanalisy_disease_id_22ab5fb5 ON public.core_riskanalisy USING btree (disease_id);
 8   DROP INDEX public.core_riskanalisy_disease_id_22ab5fb5;
       public         postgres    false    239            �           1259    19130 !   core_sympton_category_id_668e5b2d    INDEX     a   CREATE INDEX core_sympton_category_id_668e5b2d ON public.core_sympton USING btree (category_id);
 5   DROP INDEX public.core_sympton_category_id_668e5b2d;
       public         postgres    false    237            Q           1259    21368 &   core_team_partners_partner_id_c2b7bcca    INDEX     k   CREATE INDEX core_team_partners_partner_id_c2b7bcca ON public.core_team_partners USING btree (partner_id);
 :   DROP INDEX public.core_team_partners_partner_id_c2b7bcca;
       public         postgres    false    301            T           1259    21367 #   core_team_partners_team_id_ac6282f3    INDEX     e   CREATE INDEX core_team_partners_team_id_ac6282f3 ON public.core_team_partners USING btree (team_id);
 7   DROP INDEX public.core_team_partners_team_id_ac6282f3;
       public         postgres    false    301            Y           1259    21381 &   core_team_teamMembers_team_id_902c1510    INDEX     o   CREATE INDEX "core_team_teamMembers_team_id_902c1510" ON public."core_team_teamMembers" USING btree (team_id);
 <   DROP INDEX public."core_team_teamMembers_team_id_902c1510";
       public         postgres    false    303            \           1259    21382 ,   core_team_teamMembers_teammember_id_eae8cb08    INDEX     {   CREATE INDEX "core_team_teamMembers_teammember_id_eae8cb08" ON public."core_team_teamMembers" USING btree (teammember_id);
 B   DROP INDEX public."core_team_teamMembers_teammember_id_eae8cb08";
       public         postgres    false    303            �           1259    20960 ,   core_typeprofessional_listGroups_id_e5227f74    INDEX     z   CREATE INDEX "core_typeprofessional_listGroups_id_e5227f74" ON public.core_typeprofessional USING btree ("userGroup_id");
 B   DROP INDEX public."core_typeprofessional_listGroups_id_e5227f74";
       public         postgres    false    233            �           1259    19124 !   core_userprofile_city_id_4363136c    INDEX     a   CREATE INDEX core_userprofile_city_id_4363136c ON public.core_userprofile USING btree (city_id);
 5   DROP INDEX public.core_userprofile_city_id_4363136c;
       public         postgres    false    235            �           1259    18889 )   django_admin_log_content_type_id_c4bce8eb    INDEX     q   CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);
 =   DROP INDEX public.django_admin_log_content_type_id_c4bce8eb;
       public         postgres    false    216            �           1259    18890 !   django_admin_log_user_id_c564eba6    INDEX     a   CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);
 5   DROP INDEX public.django_admin_log_user_id_c564eba6;
       public         postgres    false    216                       1259    19353 #   django_session_expire_date_a5c62663    INDEX     e   CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);
 7   DROP INDEX public.django_session_expire_date_a5c62663;
       public         postgres    false    258                       1259    19352 (   django_session_session_key_c0390e0f_like    INDEX     ~   CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);
 <   DROP INDEX public.django_session_session_key_c0390e0f_like;
       public         postgres    false    258            �           2620    19735 8   hdb_schema_update_event hdb_schema_update_event_notifier    TRIGGER     �   CREATE TRIGGER hdb_schema_update_event_notifier AFTER INSERT OR UPDATE ON hdb_catalog.hdb_schema_update_event FOR EACH ROW EXECUTE PROCEDURE hdb_catalog.hdb_schema_update_event_notifier();
 V   DROP TRIGGER hdb_schema_update_event_notifier ON hdb_catalog.hdb_schema_update_event;
       hdb_catalog       postgres    false    353    277            �           2606    19692 9   event_invocation_logs event_invocation_logs_event_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.event_log(id);
 h   ALTER TABLE ONLY hdb_catalog.event_invocation_logs DROP CONSTRAINT event_invocation_logs_event_id_fkey;
       hdb_catalog       postgres    false    3367    271    272            �           2606    19659 .   event_triggers event_triggers_schema_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_schema_name_fkey FOREIGN KEY (schema_name, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;
 ]   ALTER TABLE ONLY hdb_catalog.event_triggers DROP CONSTRAINT event_triggers_schema_name_fkey;
       hdb_catalog       postgres    false    3357    262    262    270    270            �           2606    19764 0   hdb_allowlist hdb_allowlist_collection_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES hdb_catalog.hdb_query_collection(collection_name);
 _   ALTER TABLE ONLY hdb_catalog.hdb_allowlist DROP CONSTRAINT hdb_allowlist_collection_name_fkey;
       hdb_catalog       postgres    false    281    3380    280            �           2606    19777 7   hdb_computed_field hdb_computed_field_table_schema_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.hdb_computed_field
    ADD CONSTRAINT hdb_computed_field_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;
 f   ALTER TABLE ONLY hdb_catalog.hdb_computed_field DROP CONSTRAINT hdb_computed_field_table_schema_fkey;
       hdb_catalog       postgres    false    3357    262    262    282    282            �           2606    19621 /   hdb_permission hdb_permission_table_schema_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;
 ^   ALTER TABLE ONLY hdb_catalog.hdb_permission DROP CONSTRAINT hdb_permission_table_schema_fkey;
       hdb_catalog       postgres    false    264    264    262    262    3357            �           2606    19606 3   hdb_relationship hdb_relationship_table_schema_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;
 b   ALTER TABLE ONLY hdb_catalog.hdb_relationship DROP CONSTRAINT hdb_relationship_table_schema_fkey;
       hdb_catalog       postgres    false    263    263    262    262    3357            _           2606    18831 O   auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm;
       public       postgres    false    208    3228    204            ^           2606    18826 P   auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id;
       public       postgres    false    208    206    3233            ]           2606    18817 E   auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 o   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co;
       public       postgres    false    202    204    3223            a           2606    18846 D   auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id;
       public       postgres    false    3233    206    212            `           2606    18841 B   auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id;
       public       postgres    false    210    212    3241            c           2606    18860 S   auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
 }   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm;
       public       postgres    false    214    204    3228            b           2606    18855 V   auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id;
       public       postgres    false    3241    214    210            f           2606    18913 @   authtoken_token authtoken_token_user_id_35299eff_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.authtoken_token
    ADD CONSTRAINT authtoken_token_user_id_35299eff_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 j   ALTER TABLE ONLY public.authtoken_token DROP CONSTRAINT authtoken_token_user_id_35299eff_fk_auth_user_id;
       public       postgres    false    210    3241    217            �           2606    19855 O   controle_atendimento_message controle_atendimento_chat_id_59ad1b4b_fk_controle_    FK CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_message
    ADD CONSTRAINT controle_atendimento_chat_id_59ad1b4b_fk_controle_ FOREIGN KEY (chat_id) REFERENCES public.controle_atendimento_chat(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.controle_atendimento_message DROP CONSTRAINT controle_atendimento_chat_id_59ad1b4b_fk_controle_;
       public       postgres    false    291    285    3387            �           2606    19839 U   controle_atendimento_prontuario controle_atendimento_citizen_id_20bcebe3_fk_core_citi    FK CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_prontuario
    ADD CONSTRAINT controle_atendimento_citizen_id_20bcebe3_fk_core_citi FOREIGN KEY (citizen_id) REFERENCES public.core_citizen(id) DEFERRABLE INITIALLY DEFERRED;
    ALTER TABLE ONLY public.controle_atendimento_prontuario DROP CONSTRAINT controle_atendimento_citizen_id_20bcebe3_fk_core_citi;
       public       postgres    false    287    251    3328            �           2606    19850 R   controle_atendimento_patient controle_atendimento_citizen_id_2ee30723_fk_core_citi    FK CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_patient
    ADD CONSTRAINT controle_atendimento_citizen_id_2ee30723_fk_core_citi FOREIGN KEY (citizen_id) REFERENCES public.core_citizen(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.controle_atendimento_patient DROP CONSTRAINT controle_atendimento_citizen_id_2ee30723_fk_core_citi;
       public       postgres    false    3328    251    289            �           2606    19827 O   controle_atendimento_chat controle_atendimento_citizen_id_8189d62b_fk_core_citi    FK CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_chat
    ADD CONSTRAINT controle_atendimento_citizen_id_8189d62b_fk_core_citi FOREIGN KEY (citizen_id) REFERENCES public.core_citizen(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.controle_atendimento_chat DROP CONSTRAINT controle_atendimento_citizen_id_8189d62b_fk_core_citi;
       public       postgres    false    285    251    3328            �           2606    19832 T   controle_atendimento_chat controle_atendimento_professional_id_685743fe_fk_core_prof    FK CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_chat
    ADD CONSTRAINT controle_atendimento_professional_id_685743fe_fk_core_prof FOREIGN KEY (professional_id) REFERENCES public.core_professional(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.controle_atendimento_chat DROP CONSTRAINT controle_atendimento_professional_id_685743fe_fk_core_prof;
       public       postgres    false    285    241    3301            �           2606    19844 Z   controle_atendimento_prontuario controle_atendimento_professional_id_acc49a11_fk_core_prof    FK CONSTRAINT     �   ALTER TABLE ONLY public.controle_atendimento_prontuario
    ADD CONSTRAINT controle_atendimento_professional_id_acc49a11_fk_core_prof FOREIGN KEY (professional_id) REFERENCES public.core_professional(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.controle_atendimento_prontuario DROP CONSTRAINT controle_atendimento_professional_id_acc49a11_fk_core_prof;
       public       postgres    false    241    287    3301            g           2606    19091 @   core_analisy core_analisy_citizen_id_126782de_fk_core_citizen_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_analisy
    ADD CONSTRAINT core_analisy_citizen_id_126782de_fk_core_citizen_id FOREIGN KEY (citizen_id) REFERENCES public.core_citizen(id) DEFERRABLE INITIALLY DEFERRED;
 j   ALTER TABLE ONLY public.core_analisy DROP CONSTRAINT core_analisy_citizen_id_126782de_fk_core_citizen_id;
       public       postgres    false    251    219    3328            h           2606    19096 J   core_analisy core_analisy_covidContact_id_d772dfbe_fk_core_covidcontact_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_analisy
    ADD CONSTRAINT "core_analisy_covidContact_id_d772dfbe_fk_core_covidcontact_id" FOREIGN KEY ("covidContact_id") REFERENCES public.core_covidcontact(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.core_analisy DROP CONSTRAINT "core_analisy_covidContact_id_d772dfbe_fk_core_covidcontact_id";
       public       postgres    false    225    219    3277            i           2606    20922 >   core_analisy core_analisy_latLng_id_589e14c1_fk_core_latlng_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_analisy
    ADD CONSTRAINT "core_analisy_latLng_id_589e14c1_fk_core_latlng_id" FOREIGN KEY ("latLng_id") REFERENCES public.core_latlng(id) DEFERRABLE INITIALLY DEFERRED;
 j   ALTER TABLE ONLY public.core_analisy DROP CONSTRAINT "core_analisy_latLng_id_589e14c1_fk_core_latlng_id";
       public       postgres    false    219    229    3281            �           2606    19902 X   core_analisy_listSympton core_analisy_listSympton_analisy_id_d8925359_fk_core_analisy_id    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_analisy_listSympton"
    ADD CONSTRAINT "core_analisy_listSympton_analisy_id_d8925359_fk_core_analisy_id" FOREIGN KEY (analisy_id) REFERENCES public.core_analisy(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public."core_analisy_listSympton" DROP CONSTRAINT "core_analisy_listSympton_analisy_id_d8925359_fk_core_analisy_id";
       public       postgres    false    255    219    3270            �           2606    19897 X   core_analisy_listSympton core_analisy_listSympton_sympton_id_3856137a_fk_core_sympton_id    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_analisy_listSympton"
    ADD CONSTRAINT "core_analisy_listSympton_sympton_id_3856137a_fk_core_sympton_id" FOREIGN KEY (sympton_id) REFERENCES public.core_sympton(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public."core_analisy_listSympton" DROP CONSTRAINT "core_analisy_listSympton_sympton_id_3856137a_fk_core_sympton_id";
       public       postgres    false    255    237    3294            �           2606    21319 <   core_blogpost core_blogpost_city_id_096f50d3_fk_core_city_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_blogpost
    ADD CONSTRAINT core_blogpost_city_id_096f50d3_fk_core_city_id FOREIGN KEY (city_id) REFERENCES public.core_city(id) DEFERRABLE INITIALLY DEFERRED;
 f   ALTER TABLE ONLY public.core_blogpost DROP CONSTRAINT core_blogpost_city_id_096f50d3_fk_core_city_id;
       public       postgres    false    260    223    3275            {           2606    19201 :   core_citizen core_citizen_city_id_2cdb6ae3_fk_core_city_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_citizen
    ADD CONSTRAINT core_citizen_city_id_2cdb6ae3_fk_core_city_id FOREIGN KEY (city_id) REFERENCES public.core_city(id) DEFERRABLE INITIALLY DEFERRED;
 d   ALTER TABLE ONLY public.core_citizen DROP CONSTRAINT core_citizen_city_id_2cdb6ae3_fk_core_city_id;
       public       postgres    false    251    3275    223            }           2606    20917 J   core_citizen core_citizen_healthCenter_id_1f0a751f_fk_core_healthcenter_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_citizen
    ADD CONSTRAINT "core_citizen_healthCenter_id_1f0a751f_fk_core_healthcenter_id" FOREIGN KEY ("healthCenter_id") REFERENCES public.core_healthcenter(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.core_citizen DROP CONSTRAINT "core_citizen_healthCenter_id_1f0a751f_fk_core_healthcenter_id";
       public       postgres    false    243    3309    251                       2606    19912 P   core_citizen_listRiskGroup core_citizen_listRis_citizen_id_a827692c_fk_core_citi    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_citizen_listRiskGroup"
    ADD CONSTRAINT "core_citizen_listRis_citizen_id_a827692c_fk_core_citi" FOREIGN KEY (citizen_id) REFERENCES public.core_citizen(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public."core_citizen_listRiskGroup" DROP CONSTRAINT "core_citizen_listRis_citizen_id_a827692c_fk_core_citi";
       public       postgres    false    253    251    3328            ~           2606    19907 R   core_citizen_listRiskGroup core_citizen_listRis_riskgroup_id_c63e0e2d_fk_core_risk    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_citizen_listRiskGroup"
    ADD CONSTRAINT "core_citizen_listRis_riskgroup_id_c63e0e2d_fk_core_risk" FOREIGN KEY (riskgroup_id) REFERENCES public.core_riskgroup(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public."core_citizen_listRiskGroup" DROP CONSTRAINT "core_citizen_listRis_riskgroup_id_c63e0e2d_fk_core_risk";
       public       postgres    false    253    231    3283            |           2606    19206 H   core_citizen core_citizen_userProfile_id_f7615bd2_fk_core_userprofile_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_citizen
    ADD CONSTRAINT "core_citizen_userProfile_id_f7615bd2_fk_core_userprofile_id" FOREIGN KEY ("userProfile_id") REFERENCES public.core_userprofile(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.core_citizen DROP CONSTRAINT "core_citizen_userProfile_id_f7615bd2_fk_core_userprofile_id";
       public       postgres    false    251    3289    235            j           2606    19917 8   core_city core_city_latLng_id_58b54250_fk_core_latlng_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_city
    ADD CONSTRAINT "core_city_latLng_id_58b54250_fk_core_latlng_id" FOREIGN KEY ("latLng_id") REFERENCES public.core_latlng(id) DEFERRABLE INITIALLY DEFERRED;
 d   ALTER TABLE ONLY public.core_city DROP CONSTRAINT "core_city_latLng_id_58b54250_fk_core_latlng_id";
       public       postgres    false    223    229    3281            z           2606    19499 J   core_dailynewsletter core_dailynewsletter_city_id_df25d67e_fk_core_city_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_dailynewsletter
    ADD CONSTRAINT core_dailynewsletter_city_id_df25d67e_fk_core_city_id FOREIGN KEY (city_id) REFERENCES public.core_city(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.core_dailynewsletter DROP CONSTRAINT core_dailynewsletter_city_id_df25d67e_fk_core_city_id;
       public       postgres    false    249    223    3275            x           2606    19182 X   core_disease_listSympton core_disease_listSympton_disease_id_0c57eb03_fk_core_disease_id    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_disease_listSympton"
    ADD CONSTRAINT "core_disease_listSympton_disease_id_0c57eb03_fk_core_disease_id" FOREIGN KEY (disease_id) REFERENCES public.core_disease(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public."core_disease_listSympton" DROP CONSTRAINT "core_disease_listSympton_disease_id_0c57eb03_fk_core_disease_id";
       public       postgres    false    3279    227    247            y           2606    19187 X   core_disease_listSympton core_disease_listSympton_sympton_id_24fd9948_fk_core_sympton_id    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_disease_listSympton"
    ADD CONSTRAINT "core_disease_listSympton_sympton_id_24fd9948_fk_core_sympton_id" FOREIGN KEY (sympton_id) REFERENCES public.core_sympton(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public."core_disease_listSympton" DROP CONSTRAINT "core_disease_listSympton_sympton_id_24fd9948_fk_core_sympton_id";
       public       postgres    false    237    3294    247            u           2606    19504 D   core_healthcenter core_healthcenter_city_id_09c6c9bf_fk_core_city_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_healthcenter
    ADD CONSTRAINT core_healthcenter_city_id_09c6c9bf_fk_core_city_id FOREIGN KEY (city_id) REFERENCES public.core_city(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.core_healthcenter DROP CONSTRAINT core_healthcenter_city_id_09c6c9bf_fk_core_city_id;
       public       postgres    false    3275    243    223            t           2606    19318 H   core_healthcenter core_healthcenter_latLng_id_83cada46_fk_core_latlng_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_healthcenter
    ADD CONSTRAINT "core_healthcenter_latLng_id_83cada46_fk_core_latlng_id" FOREIGN KEY ("latLng_id") REFERENCES public.core_latlng(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.core_healthcenter DROP CONSTRAINT "core_healthcenter_latLng_id_83cada46_fk_core_latlng_id";
       public       postgres    false    3281    229    243            w           2606    19514 ]   core_healthcenter_listProfessional core_healthcenter_li_healthcenter_id_343ce92d_fk_core_heal    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_healthcenter_listProfessional"
    ADD CONSTRAINT core_healthcenter_li_healthcenter_id_343ce92d_fk_core_heal FOREIGN KEY (healthcenter_id) REFERENCES public.core_healthcenter(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public."core_healthcenter_listProfessional" DROP CONSTRAINT core_healthcenter_li_healthcenter_id_343ce92d_fk_core_heal;
       public       postgres    false    245    243    3309            v           2606    19509 ]   core_healthcenter_listProfessional core_healthcenter_li_professional_id_054efaf8_fk_core_prof    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_healthcenter_listProfessional"
    ADD CONSTRAINT core_healthcenter_li_professional_id_054efaf8_fk_core_prof FOREIGN KEY (professional_id) REFERENCES public.core_professional(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public."core_healthcenter_listProfessional" DROP CONSTRAINT core_healthcenter_li_professional_id_054efaf8_fk_core_prof;
       public       postgres    false    241    3301    245            �           2606    21324 @   core_healthtips core_healthtips_city_id_7ec44a22_fk_core_city_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_healthtips
    ADD CONSTRAINT core_healthtips_city_id_7ec44a22_fk_core_city_id FOREIGN KEY (city_id) REFERENCES public.core_city(id) DEFERRABLE INITIALLY DEFERRED;
 j   ALTER TABLE ONLY public.core_healthtips DROP CONSTRAINT core_healthtips_city_id_7ec44a22_fk_core_city_id;
       public       postgres    false    257    223    3275            s           2606    21292 D   core_professional core_professional_city_id_0b98d4b3_fk_core_city_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_professional
    ADD CONSTRAINT core_professional_city_id_0b98d4b3_fk_core_city_id FOREIGN KEY (city_id) REFERENCES public.core_city(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.core_professional DROP CONSTRAINT core_professional_city_id_0b98d4b3_fk_core_city_id;
       public       postgres    false    241    223    3275            r           2606    19470 M   core_professional core_professional_typeProfessional_id_430b6c93_fk_core_type    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_professional
    ADD CONSTRAINT "core_professional_typeProfessional_id_430b6c93_fk_core_type" FOREIGN KEY ("typeProfessional_id") REFERENCES public.core_typeprofessional(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.core_professional DROP CONSTRAINT "core_professional_typeProfessional_id_430b6c93_fk_core_type";
       public       postgres    false    241    233    3286            q           2606    19307 D   core_professional core_professional_user_id_099f9d59_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_professional
    ADD CONSTRAINT core_professional_user_id_099f9d59_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.core_professional DROP CONSTRAINT core_professional_user_id_099f9d59_fk_auth_user_id;
       public       postgres    false    241    3241    210            o           2606    19131 H   core_riskanalisy core_riskanalisy_analisy_id_53e6770b_fk_core_analisy_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_riskanalisy
    ADD CONSTRAINT core_riskanalisy_analisy_id_53e6770b_fk_core_analisy_id FOREIGN KEY (analisy_id) REFERENCES public.core_analisy(id) DEFERRABLE INITIALLY DEFERRED;
 r   ALTER TABLE ONLY public.core_riskanalisy DROP CONSTRAINT core_riskanalisy_analisy_id_53e6770b_fk_core_analisy_id;
       public       postgres    false    219    239    3270            p           2606    19136 H   core_riskanalisy core_riskanalisy_disease_id_22ab5fb5_fk_core_disease_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_riskanalisy
    ADD CONSTRAINT core_riskanalisy_disease_id_22ab5fb5_fk_core_disease_id FOREIGN KEY (disease_id) REFERENCES public.core_disease(id) DEFERRABLE INITIALLY DEFERRED;
 r   ALTER TABLE ONLY public.core_riskanalisy DROP CONSTRAINT core_riskanalisy_disease_id_22ab5fb5_fk_core_disease_id;
       public       postgres    false    3279    227    239            n           2606    19125 I   core_sympton core_sympton_category_id_668e5b2d_fk_core_categorysympton_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_sympton
    ADD CONSTRAINT core_sympton_category_id_668e5b2d_fk_core_categorysympton_id FOREIGN KEY (category_id) REFERENCES public.core_categorysympton(id) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.core_sympton DROP CONSTRAINT core_sympton_category_id_668e5b2d_fk_core_categorysympton_id;
       public       postgres    false    237    221    3272            �           2606    21362 L   core_team_partners core_team_partners_partner_id_c2b7bcca_fk_core_partner_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_team_partners
    ADD CONSTRAINT core_team_partners_partner_id_c2b7bcca_fk_core_partner_id FOREIGN KEY (partner_id) REFERENCES public.core_partner(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.core_team_partners DROP CONSTRAINT core_team_partners_partner_id_c2b7bcca_fk_core_partner_id;
       public       postgres    false    301    3404    295            �           2606    21357 F   core_team_partners core_team_partners_team_id_ac6282f3_fk_core_team_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_team_partners
    ADD CONSTRAINT core_team_partners_team_id_ac6282f3_fk_core_team_id FOREIGN KEY (team_id) REFERENCES public.core_team(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.core_team_partners DROP CONSTRAINT core_team_partners_team_id_ac6282f3_fk_core_team_id;
       public       postgres    false    301    299    3408            �           2606    21376 N   core_team_teamMembers core_team_teamMember_teammember_id_eae8cb08_fk_core_team    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_team_teamMembers"
    ADD CONSTRAINT "core_team_teamMember_teammember_id_eae8cb08_fk_core_team" FOREIGN KEY (teammember_id) REFERENCES public.core_teammember(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public."core_team_teamMembers" DROP CONSTRAINT "core_team_teamMember_teammember_id_eae8cb08_fk_core_team";
       public       postgres    false    3406    303    297            �           2606    21371 L   core_team_teamMembers core_team_teamMembers_team_id_902c1510_fk_core_team_id    FK CONSTRAINT     �   ALTER TABLE ONLY public."core_team_teamMembers"
    ADD CONSTRAINT "core_team_teamMembers_team_id_902c1510_fk_core_team_id" FOREIGN KEY (team_id) REFERENCES public.core_team(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public."core_team_teamMembers" DROP CONSTRAINT "core_team_teamMembers_team_id_902c1510_fk_core_team_id";
       public       postgres    false    303    3408    299            k           2606    20961 R   core_typeprofessional core_typeprofessional_userGroup_id_eb6b826e_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_typeprofessional
    ADD CONSTRAINT "core_typeprofessional_userGroup_id_eb6b826e_fk_auth_group_id" FOREIGN KEY ("userGroup_id") REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.core_typeprofessional DROP CONSTRAINT "core_typeprofessional_userGroup_id_eb6b826e_fk_auth_group_id";
       public       postgres    false    233    206    3233            l           2606    19114 B   core_userprofile core_userprofile_city_id_4363136c_fk_core_city_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_userprofile
    ADD CONSTRAINT core_userprofile_city_id_4363136c_fk_core_city_id FOREIGN KEY (city_id) REFERENCES public.core_city(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.core_userprofile DROP CONSTRAINT core_userprofile_city_id_4363136c_fk_core_city_id;
       public       postgres    false    235    223    3275            m           2606    19119 B   core_userprofile core_userprofile_user_id_5141ad90_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.core_userprofile
    ADD CONSTRAINT core_userprofile_user_id_5141ad90_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.core_userprofile DROP CONSTRAINT core_userprofile_user_id_5141ad90_fk_auth_user_id;
       public       postgres    false    235    210    3241            d           2606    18879 G   django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 q   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co;
       public       postgres    false    202    3223    216            e           2606    18884 B   django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id;
       public       postgres    false    3241    210    216            [      x������ � �      Z      x������ � �      Y      x������ � �      a      x������ � �      b      x������ � �      \      x������ � �      X      x������ � �      `      x������ � �      W   �  x��V[n�0�fVQ�]u]DWP)�r�78�F���&��2\��Z>�'>>�Np���8(+�*�	�
�	����r�>rƃbܚR
5���G�P[����8�[K�?>��PC�ISZ�[g�Y�a��k�4Ե4�Ei��+�?g=�h~>��ח�լ��I����E\@�U"������98}KY������(��Ɏjr m��QwSM���T��*u���5:-�&��(�Gb �nr�kOX�R�*����Gd��펷r����ȿ���/K�w4��I!�5i�Ec�o�uQ��$M��ۻ���p{5�l�����S<ߐXG�_i�-O�9���=p.��'���'x�� ~�N��p�~ءՑw&U������Y��Z�O��ڥ���ժ�QI��!g�:�B�~r@a�axG���jej�.��k�ͬ���P�H'�02�OᲊuA�^bNBN�q5Ν�!W��K�;��O���6��      _   l   x��A! ���
�U�)]J_Qc�P�A��p3���rLA+�*QC��A�&Yhg�y!$�䄡���ƂYΈ��w��t�/O}����c�cԗu�\�?w[�sI�      V   J  x����n�0���U��`�2)
����C����B���Z�DD����y�����+a���Ai.�0�䲈���r|;\�/�� 4'v��[�F��ſ���ޖ� ��?t?�t�;j�$���79yS����N�R���7j}��f���/�@7�ˈ�����e��h��Y��!����9ό3سaV�c�l���,yȋ�����������}Ұt3$Q��f��/5���R�[�!ka=��	�#��0ԁ����y�1�"7�
���5�C���,>�;�~�3�Q$ܚ�'#dWS8�݉���=���/�@���׶m?@�bp      U   t   x��K
�0 �ur�ҭL��|��nܺ�N�m�DDJ��{z���)�K�'UZ�/����#���h`�)e����������ʻ��wi�.u�����}�1}����&k���(      ^      x������ � �         3   x�3�tt����	rt��2�tt�2�t��rq�s<�~�ٟ+F��� �J          =  x�-��u#1Dѵ+�9ć$���c���t˲x�"�d?�sS>7�Pp�R����O����\C5�T�u��܎����d-C�%{����Ac!��Aٖcّ�ٕ�'*�{��������C�o��|��o��_���[�K���W��9�����ċ�ċ�ċ9(�h%^.%^�/]���|�J���x9'��W/K/[o/m�m�x۵�vh���~��:x�������Ko��Y:xgf�w\��I��u�l�.޹�x�t�N뾄,]�k�xwR�wCw�
�ꅥU/-K�W��+W����R�W[�WG�WW�W�ƫV��R����]�ס��I.^o5^5^Oz`O~bO�׋����5)^_�'��{M�׋��,��E3^�הc������e�3�^����Jc�ľ��_u��_yX��0V�=�og��c�0����b��ߊ��+�L���|���PN!l�4¦RN%l:�t¦T��-�g��3v�����C�|Y�\�B.V!��gܖ�3oK��y&j�<#�D��Z"7���U�3VK䙫M��D��6��L�d��~1���'�?�Ͷ�         8  x�u�ώ�8���)x�U��=f;l+�Lg��FZ)r&�&��e�{�Ӿ��N��ڮ�]e�[(�*|	�U'у�cY�9�eݷ�(���Q]�K���*�s�(y03`Q^ʞ���Ԁ�U��a:࡙Sv+�k�uUSG���bN�1�vA�1v�%2�h$�ʩ<���-ʌ@�Y$*ή�.D��"(��K��Q�˙S�֕m45�G�L��qo����9 so\6��Ņ��{����~+��Q�!ɒ
	`��������h#���Sݕ�T�F0^��ջgP��X�{�9�Ժ��*��J?4?�:Z=��,RV�v� ���"�R�0p�W�������h�+��J��p�f���������_�'ٗ禽���z��߷���0FEƊ}$��Y��<0�g�-�#�ɂ�s�c�^��	��Yd�#�lE��	+OS�\!f5!~}�����GI��UA��i�-�δ4%�R�oiʔ7H@�R�;���Rve��D�K1ev!
v��P��qe�9ƻ�"��R��ƀ�TWb��C;@c�!�����'"�=m������h�3fN�43�p����F&�#tw�om�ڢ�D	L�@�bƬ2�g� �yh4�6�0uN�5�u��]���ɪ.���nPcH̙�B�n��&�A���B�v{�پ��h��l��F ;+-��F8;,-G�F(���Y�ڶ$Y��Cd1�7�I���dP�$�T�KH�:'��t{W�ҁ�ƪf���vk�2�?���eĤ!�\F{����ҿ�'��R[��!&̡����A
� ��$�$�_�q��BV�{\�?;��&F����X2G�eٹ&2g�%�A&�����	��Sդ�~��]�ڭ��K�T�p̩�����S	e7���[����H�X��
��H�X��	��J,LjP���bzk�>Jalꀾ+fMơV�2O2uz����F�������l�&Jg��`D��A� ���^��оsX:�LX� �m%{�W�~L=�Y-�=&�ۊ��)���C" u��W��乌R�bx�fB�2wy�؃`F���?n��T��Rbx)~�@(��<A@��H�@0xpZD����!����s����w�&���a���������M���kY��I��c[���o��Xv�,�c'�
�k�D����y��v�����}�f���Tꊥ>��<l׃���S%E��?M�l������N��2U�����z��t�
Y�J��yϟ����D��KT�ɿ�>���0�QO��*|����Ҽ�K���L�&�l��T��XB���Dj�;�U5�k����_h��p�5��u�>�O���v���ޮ�R��яbm�/�v�tmm�~����Ng|���Ey�4w]W��I������v������`/�BQd>8l�?(��3�ۃ�g�0��p"B�)�7��s������sٖ���VA��T�}��Y�m�\*���zʵ�#S��bAz^�1l+��/�Uu���`��Cɔ�� ��v�g�/���Ihx��l�TGY���i(T��
���4BD)d��h���&���5��      "   6	  x���[������E?�f4f��\*b"�7����@L�	n"��\T��'ժ���b��J���k��r������#<E@?�@�Q2K���~`�c\��y1��b�G���Z;O�jv��h�X�k���� ��s�;��c%0� �s��©�������ߪ�������9���D_�KOJ��x%9G.j�I����w�P��Į�o���2׬������O��ѹ�SV�!��E��wY$ �KO�B��>O�|Q��k>�N��� wm��n�
���F���qP�+�v~� )��a�NYF��KH|q��9��2V������E2=ň�t<+�����S������i/�ާ"NT8��8��Y
y�$�
�5�t��y����![�9�g�eY7�����Ep�Ci��������4�(~��D�6E�;X� 	O�5FV(�y�b�K̡3&i׵�V#^����3��}��E�X�;3>����)�sr�$� I���6�"@�O�k�#�o��<R���t��SV�5��pdtᾂ}}����v��Z
Z�U�[$aT&N�RM�"H�T~��8��d�f��jL�3)��L+�;��6�Ag�_�'�lP�p��wF<�	)�[~�$h�ȡ,^�U�/4��yYE���̭�
p�k��O�����tE�<d�����p�o�%���9��
����qR�͝:i��1aya�R�aA��K�_Jq�j߸�
�^�
]�\�z�F۔]��z�.���h��OM���$��2h!��&�"�A���o-��]�e(�SL�Z]�!��pf�ty�u�N�+���7�5�����O9��n�;��<����E(��W��1�����pcWL�l}��Q���ɭZ/xi1�2<Zs�gl�橷���6��� _� a1y����޵���*�1�s ���$���fݍ.����'x��;%�{`���ݬd)���_b�����(	φ�Z�l2ڈ[��#ٿ3~���t��ny�Qp���L��@��t���t-}֤�J�u�0h3)�㎚�pz��2�,��V�<ܝ�3���D�Jno����DQg˱�}��,���6N�π��ST%�N�;-	OYϊ'�g�p-C/�MnAz>��M�����ț$�T�Ae���������Z%��l-�[��������� �(�g�D��:m�1�nNc*��mǘ�M�6�bXI���8�kab�p���`�U��P���Q��.��"���a11�b|���y�è�.7�z����t-v�����G��I��p�n�L3�.q�L�eS��s��I'�V�C��Yg���kK�q���y �L��8��i��5ex�?ޓ~l�:q7�ŹÙ�(��{(��|lf�{6�_ �wH�iQ0`%Q@<~�u��;�w�]���G���B��^���G�z�L$Su�8�=�h�k���d�ܪ�����z�Γ����-�i���?{��V�9�>(҇�Z��ޑ�B#��<-\-�����%b\k��/eIo���e3�v�,q��4_��l|����f&A�X��L�����a�Ȱ��<-�i�ɻ ZU���:ޮ��޹������v�F�fG��ve�J���[���K�� �֏�9	K�xP<DK��i]�)"�BN ���%���KYʹz�,���;c�۝�Y�ka�9!AuY��Mr0�$��Q�{�N8�H A�X�K��OQ���x�iϹ�2E���7���f���*�co���(P�L&�vz:�=�kn���S���l��ܻ�:�����4��r+��^ޒUj�-䭎I�*̂\I�c���-�ֵ�ɝ�`	3���Q�M�Ur�O��Ep�S�,��\�}E +!$����c� ���n|(3Wg��w\V�a�gp��ʫ[.��j��O�n�7�ڼ��_;E�6�,�,���Dm�K���铴`�����n:���z'`}��Ջ�뮊���b7���u���g^V[8��	���Շǂ�j-��fa���'_1ka���n�ΐ'j7���D��c`�A-�!ɯA��C�8^�#���G��N��4���t��L-^���9�(�
�m���;*��n��]�����Ʀ �S��H�XE����?��{��� @�]�_���c� ���=�����ˮ���z{;��V(���m�塷�s(���eh���C�&��uE���*D����l��ִ;G"��שѲZsYԬ�Q�Gz���YX��a|.6ӡ��F����n����~�������>�Ds���׏rQ�π�kZ�'��tB��D���Ц������������ |L�G      $   o   x���D!ϡ�}&
j/��:�xa$�CX=�/f�c�f�	�,�fǎy�i^0�9�2	.S�6'dO.��LȾ,��6�zz��[r�����K�j�MQ�����?qX      &     x�%�ۭ�@�ﰘ����r��cE&��9��⧰]��#v䮉ڵл6f����A����V(5(	u((M(!-()m(1(9}0z&0z��sd0z�0z0z�0zV0z�0z60z���\��\��|��n���<��<��������|���!� �"�!��>�{h����������I/I/I/I/I/�-�kH$�,$�l$�$�|(z%(z�(ze(z�(z(z���^l��U��ՠ��C�kA�kE�kC�kG��@��D��M�E���z���a�`�b�a�c�M`�Mb�Ma��f��7z���=�����3<z��������+<z���M�řy������l��B-�j�X��Z.زɖ��l���-�n�x��[.�	���쌯4ך�6;�+��U�����v|�Q�ƽ7ø�f�ތ����g��Ur�+�w���^���ܓ�zeR�r��C�P�ѫ�nG�J���Z��D�+����;�ʥ��zi���flc�*�����F�f���+�^����g���ٛ�����?��8      )   r   x�E̹!�x�bskџ�jq�5��`;��ⷜX�DB����´��:˩��@�M��:,�1���K�)�ǙN�n�v|9�$>-f���?�7��ܕ��xi���;��>�J"      d      x������ � �      j      x������ � �      h      x������ � �      f      x������ � �      +   i  x����n$7���SLX����� )�\�k�1�����N��	R����Bj���!`��"�})�	3��̷ 3�º`M��r�~�>�j�pb�>��O�?�^�y��2}�?��O�_�w����X5�B�Z�X�J��1�E�d����TZid4�Ѽ�@�%�R$U����V`L��RjBjX�8�4�Ѹy��6ȸ��i4�юVʒ)q-y�U���.�-�Z4���-�oi&7��@ki�}Z���W�惴��:�@[���P���[ʘ�;�	�9	 ��N��M�V�+�
�Һz�,d���!�p��ޱ�w4.a*�H�o]�c�+mh��} 1��5C��+yL���O1'T`��ze�z-�f(�=C�
���U��z��)� s�Jk�^g�n�kAN�SJ��q=[s��8CT�4Y8��@+�4W��3Dێ��
iZ�j��A.cc���{����Vhn�1mc(>rMY�W�6w��}��;0M$���	2�U�8���Mg�q��:�$c_5��|�ƶ����W-8A߲�1	KӴ���WMv4�J�X��p_i��
ul�V#h)�אZUk���=i�
mY�%�$,�=�^���I�Z�Y��o��I!���"�zS�`ճ�Ą��~�c�z[�y�]�Vq�rɺp�:6koˊ�r�ˮI�aQ��p�H; ��P�F�vk��w���X�lð(m�ځ�赼{��<M�6^�	�;p��^K �9���g�c�@�m0b�v�.����*�+r*�氞 P�ܛӁ�6c�?�7;� A����#.�<��n�m���+���P�	@?�R4�Z"���hԾ/�֮Fy�7Sj�V�������/��ݗ������Ə�ų�ꒉ����S��[V �	`['�I�% �����٩�I��# �Q\���=C�;\ J��9�j�ȳv��lQ�bQ��	SE�|�"�U������u�`� �$��a�v�o.�������_��S/�Q�fd_ժ�2\ehm�[��Ut�р������������w~<=�\�_Nw�?���c��"��vq

īc�"����l����\2\�x qu��cҖ{* +�[�W�=��X��nnn�����      O   �  x�-�Kv1������.��9R���62�'�[~�%_���i�ш���R��!��`�ӭ��Ļv�I�W�Z	���3T�!�4S@�9��S@�I���]?i�@��/���+�W
�!@��@b>��[ �H|� ���Ǧ�}D��{�c����\�Ԭ�W���G��2���ų�kkvu�#��ϑ)��g�z�&_��jh �wF��>HОP �&P�h�5���H�4[ ���! q	�I��:!@Ҕa�σ0�HDk�L}KkQ��f��{i��{�T�k��$�Y�4L��-Ӂ���ad��~�r,��r�L'��E�t�Ix���؄��6��פ�e"bv~&"f����T�|�;�o�K�E?f�1�ׄ_�	�!��9n�I�a�y���L&W�\��5љ����&&�چ��9Ӥ�a�����>�2I�M�rLla^��~����"��      l      x������ � �      T      x��[KoWv^˿�� ��4��|�^��p ��R&��v�e�j����Z�6��f� ��!(����O���ι�j��˓L 6Ev=�y~��[w�Fk�����x+Z�o��o��ht��Ns[�(v�������/����hn�"�х]\N���Ȕ��X�*��D.�'&+�����įL�[��S��r�2w�d>Z�)�8壇U榋˹�GNm��������98�|��q���7��p��1���:������Bn����f�/)-^ࣚ�L]���k����|��g���%��şm~��������l������d�M~����~d���g��e^���O�V�������"�x�2�Uɗ�/~ʦxM#��������#H��8z������_O��)���Ǐ��o��z�`o����g&�TS/�T�|ZT8�I��ğm!�N�m4�ٙ��}d�rmAC�;y���h{��c���H$�x���|���3K��A�N���ۛ�pѷ��.i�=���>�����4}���a>	^�_0���{����K�w,ǈ���ч�jN(�b����m������!��2|����՟����}�����Y�Hh�zb��FS�N#�zjo��śI"b��Q:�y	1򖣬��ƛ#�1��Ex%�;\��]x���/zf��@p%�S������?�S}ӯ��d�[2��u.��5���j���wvV�~���T�q��hmA@*�G�L�8<=9ztW�~�2W��W��D>�q�e��p�A�.�E,�J�.}Ls�"s��k�Vkt��m����H]Q�*8AU��i��Ɣ�p�6H��0�&D���"Z	�Ut����5{�@�^M��H�xA&*ZzL��B����@��ÿ�p�o���;�����H�0���N]?j�ؙ+S�eck�P6�� Q��P����h#|����M'�u���Gg���h����ad���5��r\��R�h^/!O�������c�����!�"r�|���G���4��5ą�A��F4]�֗�W։�@�ĥ��9b$<���;8����㕇���	����~����D���P�s[J��S#�[�-�#z�9�F�+B�� r��f�Xt d�Jr� ��N�R��s!6�xL�s�S�b������Ѫ��k?aP�}��*p'�0�@
�f�_�u���)R5g��@���9zm6d�@֟�&O2p4�}�+�|�^���Un������ݺ!-|���7���W�}T�k�{���@��8@��׿Q7�Z�D�W�̧����o[}!�5 ��5�@���G�B�_����:�4� "��̻zF��f��RQ��$�7t6���{�M�O (FǄ�a�؀4r�4����Ǉ�	2¹p3��sH%"���4zh�A���s����ה����ԑ�����˩d����J)�'6A��o������}\��t�*vS�r+����'�5�X�T��bR	�	���Y�-JG���a>�ܜ1l3T{f��c_*x��40�Т�^;���@2�/4Ų��Bh\�c���#.�>RmxW�s�0�E�HG�yub���� �/snq9#c�x'�������$F�p�_@-��KCƷ���Ρ�B��H���'s��/^&S���G�*1��WH!�}0�3� �8y�8gʆH4i�aa��� λ��C�wnZK>i����G�jD�3��ʘ�2W%�x�#L��ғ�B\
b*����J�S![J�X0�hL�مO.\h�_���Ş3��\.9*���VE%��0����9ZOFj�Rɒ��L��u�7�Q�673�>��~(�%~J�]�)[�$��� �r��1t ��@�x�r���|��jĂ=��f���(4_��Y%�<�ϥ�,���^�%�N��ˊ�e��e`� �������e]T�T���{�_�dj*�X]W��~6����x��D��̬�@��
ش!-�O��_#7#�͈������7���F1�qq)0��(����� �̩;}�M��S�A[H{�9�]�{j�fڦ=H�dP�^���?3�[�ֺ��x���֡j�BUA�kxW�	�B+��K�?�o�M�'� �m��� w�n��l�����te���W���ֳ�P5� ��M�L�-Ă�3��"��$�H�V�(i�8؛%�!<Щj��Ѻ��t)"A�)Ki�T>`{��Z�FE�ęUePϏ�W��s���\*��8��J�B��Ā
�E :��KbuW�%U�.@1-	�3�L#��	zmm�}�)!Ve@��e&iYh�Y��9Sw=�k��!	�Kd��E�p� aC�At֔�'���}����൚�L�ƭWQ't+ņV�E�/J�]8?��&�ĹO-����f bb�|f�?���؛ω�����UǾ	I�Ҡ�nਠ��dp^��X��+6j��_�C�3��Ʉ���N(��pɆL�!�h=�����Rǣsp�7������=ϐ �#�xv_�?�b/�+���������	�:"�e"X(���褙v�i�{n�����M�=��s�hhM��;\Q�ep��0 �;��A�Td���j�U\
����6���**�8�Qӵӟ�0I�#K�m�0v"$2,�ku�Yg0rN<x�S߱m̠> ufA`&u	�IF7��a��Rۡ��S&���'& <ހW��<��ؗ~���[傑��a�g���jOxk�:��Nx�����it��[�l?��t	���Lx
'#^�����g{u^YhCZ,�3����4.��Ga(�ۚ��\�I>�1���Gږ���ߪ
��>j�ʵ��2�;4Z�L��b�̦�xJW�����4�.)�9=Y1,S���ݙj�w�����!I�dIy�<N��x�?2,!�VA��Huj���M;�DL�PUf8y��#b���e�,�)j�MV�v� ���;�F櫒T�>HЗ՞���ZBጎ=�b9�i��N:�K�-O2�w�i�MA��;eG�i؋o�eIP��&;9��$�34Dպ8�Na2����:������@���uG�2Ъz2�=ܬ��U���S�P:Ȩ
1�i����I�2�T���yYhm%U�.EH2�;���qֳ�K�� �3֯y�"���gV�cu���%�c�(��:�@�CIl���	׬
�o4Yg��*V2�@�x�8����I�`�U,~�]��i�f�#����~������$����1ΏN,���,4�B2dK*��mgu�!�Ҥ&/f^�@��r�K�Ώ �7�J����b�'�A��"bʩ#���(�)lP��ᚊ�G�����֐ηG���L�@��ԛ"#dٵ@{�}M�қO���=m���{�ZhV��`�����������ha4C�퉛�`�l-���X��(�І;�����$V�]�&�9��ą�$)Cd�,\$e�(P�ΫI���-_���8Nq'lq���k��l��p���咱yӃ'�G{����'�}r�}�����):=~r�������ͤ�_�n�҄��Q�k��j���W�/{���>��;��Ͼ��V�V�_��E9�g�;�o}����9�ݸ���� ^�t��٨k[:��r�����Bh���\?r�r[W/7���^�$�k�!�&�e�&�Ȃ�yv�D=��U�~��y��y��y��y��y��y��y��y��y}�x���m�g^�Jq��i�k-Xx�����d�z&}i��V�W: e�ڪ.��V漎���e\��z3�r�xI�9��(��B8g�a+�l:D��jj�a8;g���V���e^ I
nÙ������f�KC�H�g=B��%�X����	����fdF�������@�yr�M��ҭB���?F4�ꄩ[,����mT�6�[m3���/��m��<f�p�ahʴx	�߄ӊ�J9w1�j�p����â����8�+��{0�����-�6���F�k,!߼��K	��U�Z��X�Χ�{��c�K�	!%7�mB��r�7� �  �Im�X�F1�LB�N���=!����K���>3;q6]���^[�'?[\$E �B�%�޸�bj��R��7�^Ki�����K�k'�ə�2��yx�x����Ϊ C��]d���9S;3�s���m���y��=n?���.�'r��`�r~�}����Z|��l�� /ѭ&��*����f6t����`�����_ɹ\&f.p� ):4j��Y���;�R�uhb	̜�J�~]`�����@�B���h���y��⻁��4�Qu�XQ��y����ͣ�;`Z��lfCc��O
��T�_��$��K��,�����)s��w��z
��֎ o�d�iLK��[�{���sr�����@2��+�} ��a,�]
/5]��H�$d�,�B�{�b����_/�fZ�:c�{7��Y!O���-�\Ϸѭ����'y��������(�tq��9�u�ǁ�笷dw�3����&�}ᛇn:�ǹd�I����>Fl�6:��$~ZטW��/���;�;[����F�9d��cSʗ].f��m�-|Ӿՠ]����m��ӱ��2����3�
���MLvg�S<
sb�K���o���Ə�H��h�W�ERrIO�p.�iӯ���k�۝qX�d�r�:G��Ց]�_~Й^`\ƶ��^Cvٯ��Jkؼ�s�D��c����JP+nUi)b�U�Y�ʅ�����n��&�aC2�x6:"67s�b9q����Q��o�̰c�I4�Y){���u��T+������®S;oof�uMQ\e�Vߺc�θ:���#ҍ:�kw.n�Ǹ������R��˩�7[za%e����Vq���
��ef��N��vC�w���³ѤKG`�Y��|�3�fH��Q��-����9�|��~���v;#M�1Ժ�Ʊo���ﮮ�� 6�Ù�N�U�ۏ��z�J�W�Wp�Jl�
{��ttfɛ��F�wG����)��w��_����?��0h�nͨ�ƣ�͵��:�ag�*L*�Em���'�]�:鷆�-��.����0��Y�|~�X���2�
��D3�b��]!m��S�m%9G����c�-4|:�4pԝf6���ϩ����۔�J�d+��S#Du���g�:Ѯ�Q����h<\��v�'���h}wsLўr��j7#��a�gU�Aݝ}�9e��>g
�/�H��u\�	�\�c�IF%R�����C����Gqxf^�"HU�{K�H'���v��BX�F;��NG������)���O?�{3V�|2��Mec�����11*}u���Ǳ-�DRTJ���r�	Yb��P��A�*>V���Di���Ĺ����9[(�f.gI+�@�6S骷3���Y�'ǣ%��7v��ڱ
��R.S��|ug�?�[� �iEH;c�&��}�1��0��Tw(��Ȍ"��l��!-d�!_#<c$��-{	�L�!�W�t봗P�����|W��e&�����q��+�n�ё���>�� ����      -   N   x�3�J-.�,J,9��(3��%?5���D�"$�D.#N�Ғ�|N]].cN��b0�˄385W�83�$?7������� O��      K   �  x��WKr�F]C���R���d[2E�HG��7rD�y *�n�c����+'oq�� ~ �U��CX�����o��N�$7yjJ45w+c3�0h�f�M�/�9�4�V(�%тK	c�8��7�$����
��7Yjr�.�KZX4N׭M0�Lz?���a,zq����,�9����:���Z5QP'XC4=k�onnn��(E.����`"D?p�o,��~��ۜ9cT�X��ڜ��߼1�l���S�$�F3�WE�:�P�6��6|�×ѱ+r���Iz���2��@�Mn�m��SM(Ɯ���XwQ�~���4o�?S�ӵ� ��.��ӊqoKE���f�ҲJ��1$^V!�ę���O���qS=ND�i���Ho�Po��K��٢ 4�E3 e�w��<-\�F'�#t^��|� �Z��Ֆ�+��Hzv,2��P�s%KS��,7�v��������,|we*W�w3��ľ����Hb�0@mN�*��+�*0 mZ�Q-ZP�-�e�T6�|(�3P�K� 93Th2u�-o�g;�ZN�?�셺���q�&[u g�B�{$2t������VvS�W6w)�»�c��k����S��s\����y?��,w��Di�ޮu�r��'��63�$���֒s�pW����8<^"(�4c��Z��Y��f-˖�I�,3��}�TZ��\��s{&J.�X��`b"4�鲤`x?"1hH�`I��7� ��e҅�?�d� �������*���!	f�LF�ϋ����c\p����+�梅�Γ:M�+�~S�6���U��`%u�F��{���qK�<�۶	���|^����/�"�HnaSW�XO�XH�`iM���p��7��677Q,����b��u4xk�g���>@�Z!6- ��-+K�� �&Dl��o�p�E2]�Pr2=K&����.�5W~h9#,�k1������*J�O'g'	� ��1J�ק3�b�L���Kt�L������,�(g�ysH�_/�C�N�g�1�g�*��Ox��l|Q��/�~pN�jg������3��b��Y%��w+� ���C�Q'�7�qT�T���I�o���7�y]��L�� ,w�>���C��=��K��V��m�)�;rbC��]�9xmA�7�A���y�����I`���MH��Ĥ�u�u���<4!���Ow�����k�M��RbS�{0M18鞛5d2����U�&9J
ځPK��Z�2%�AEIf���Kg�m4��U#	W���P�d���' ���
NtdZ'P�;PlU�v 0`U�j��2� �E�B�C���&A*
���C�qCM~��ӫ\4�8�g�FP�����U�Ђ�\���Q� �Ф�7Ѐk�z�>6��~B�>iN��b^�m3]ZQ���|(�������K����� ��j�Y����y�1����B[���0�ѣ�
{��+ �IxI@��eha`om��^��3�bJ9��`�i���ۀ���p*����T5�@�"�:��Q�KE@�^�5�}�L3�}}ჴ���_�2X��k���OD8~U�#Z��K�����U	������!	ԍL4݀�4wi����͆:z�����?X1S
      M   �   x�%�K�!��a&��]���1U���Ԇ�mvp�*sY�]�[��a�u�6K�ظ�ڄb�lsd)�y?6���l��r�T�Qd�Z�Cpe^B��%'lT��� _/�����Ъm�P�R7��h�=4��/V�:���g��e��2rQA��
6�*�`΃���_���G��ȭѡ�=և��o�G�zP��q�B{${�� ��?�      /   !   x�3�N-*JTI��HLI�4�,����� _�p      1   p   x�3��,KUH��+I,�ҹ
ɉ��
ť���@��Tg�0O]CK�Ng�`.#N�Ë�*R3�X�]{bNz�ᕹ
��@��\��R U�b�_�3�!��D�tvv����� Z<;�      I   �  x�u�K��0Dǰ
�B�g��Z�2��z�!)�L�}l���@^HZ�%�`�,����ğ��Zb�l U��5I}'}��ޫ��6�5�*�$L�U&��r�W��t�R}u|'�]N�S#�U�#�@����n��F����,- s�f>��� ����I�����<A9��y�x��u���S�^��u� Ih�@�{��0)�(mfDW� ���և�*IM�A��k�N���D+P�^u�D҉�1 �`e����̟3�K����S�sl�n ׬��V0��K&�|3�Ypz���nE�^2������:��?^v�dQh�r�vu�%����7�vY)�l���{U�C� �v �h�#`o��F-,O�W�.�4|^l"F"��%�b�t✙�}]����ע      3      x������ � �      G      x������ � �      C   �  x�m��n�F���S�X�[4m���Ф��1��E�$Ҡ|�a�s����rJހ/�ꅲLl�I}���*�XeU�U%Y�ߴ�a�X�¸�)9�.�?�}��B��Ma��G�Y%�qM�?\��L�BS�cU^��\U��S��M��ͺ�E�~�����y�3�00����a D��i:��ي�O�[��$',&J���$yr��8�����$#;p����Z7}'!,��a�0�������Xm����UH���I�*�l�/'KZ�Ki��aE|K>�Gfd�g�R����d�e�,r�a��|���M-!��V���k�-%3���#�&w͆�u��ݱ���V��/=��~���1_�.��Rh�#�1����KV,�
-�m8�e���~��6X�i	�6��j�W��H���f{h���6m׮�����,Bk̿7߻�Q��cFi�7��i#�~��m:`�VHD^sT�3,�4�f���j��^ =��|�%�	����mʺߋl�Umtu �G�|�j2�����D�2�v�oU���a�%��.�*�F{`�H@�Ɗ�#�,9<��@6�K#��Ûa��h�M�'�y"�h[9:.n�|��&�x��m�D=��T�}�k�F^�#����2D�i[y���{�c+��E6��b�g�_��Y�[h���G�v�mk��H���b6���q��7t��ޣ�k�Z�� �c����I��նvu�W��N�MA #��h6�U%*��n������ƍ�����t���u��)�Y���4SA�?��C��&Nidjs���e'
̱�iB�^�o�_=
�����(/��nǡ��P��>%2�>�EBE(��A<5*9pD��?J�v��57\4��#���a��[�ȑ/о���/�������R��s�G{s���<?��ޟֱ[�e�K�Z���Jt�"9�aW4�_rW��#�*:�_7�S.\�=�s/<w��2�v[��j!5�{.&�=�T41��5��N�XF�[�a⇰�J�~>���j�����8��_���d�T��3� �+tLQ��I����c���*Nʲ�ќ_��������+r�����z���)ڸr���H0d>G�3�m^&�0ӵ����we��'�Wl`���|�]\\��ip�      E   �   x��ɍ0��R1�X����_�r�#�	8�R;�t+�IN/5}��G�~��'^\�1]����`km���q-=]��sA�p]�W��0*�Nq��; x�@� �q ����s���\!��'��=��v�_@\n ��@<n ~�ϟ�I�&\      Q   �   x��пN�0���~ ��!�����h$�Rɺ$����v�@00�y1\`H�H����<x�㗁��vI3�0~������!���Wa�>�,}�1�����V�e9�BaP<_��fu�D��s�G/��Ԧr�-.��,B.J���5<��O��\/�,a��<����U/��3�\�g�Ox�({x�k�u���c��ۚ�"����LJ��<��=r�M�R���0�X�2���a�$�Q��F      5   �  x�uUM�1[>K�g��.��9*�0��"/3
	������4~�K,��~K�Ƚ8ci�2�
?%_���l��"���/��QJ�έ��o��� ��s���Iވr)��i�9[�m�MY�Vj)�N
 �Y;[�aj�1$�V ;�Pt6 |�s�]M4Lh�!W-	LKG�t^Ns��bdph�!� �\	��_��@H0O��Ү	�cba� :�rx�F;��7�&��/�+��������(Z��L�h�{�j�d�?t�kϠ�p�
{Z�O�6ˊK�˹���Tx�ז���(� ���P�~�J��%}�=c �b���ҏ�G@�Vj��ؕ�Wy�}����Η��K�������y+Y�rx/���5 I�+/L��1��l_���H~La	�W�_6Uti��U����?��Q�n��6��|���_]��.!��_.Su@XZ�W&��7@�.����=�̉��~,���R����VLⰨ,�=��}6#D76@�fv lb�����F�M� -to��r=�z u\s�ɉy��@f�f�~V��;��Adմہ��ac�ۛS=KH��y]%���<t����;�f�s��(�䨎�{ȅf�� =���m���'�={��Ɂ��z���ڈ��U�AT�
Rk�!�����[ވ�u�sa����q%{����j�gE��倫7�?���_|2bM      n      x������ � �      A   �  x�}��r�H���O1/`3��p牄��dAJ�R�R������$W)��L�y���lbi/DQ>N�>��0���|:
�R8�����	8����K�ӻ�8Z7{�e��\�wsHd�K2���$N3p�:�W�Q�u����n�v�����$$arB���1�+eʶU$mޔn�'U=ui��z�z��)�"�!!��Ɖ�:�0��nG]���ߞ�eP�Sg�!���4�)֓���"��2��vT!�r1�'^�=��`��N� ��T������W<\1���t`8�di��<"I6�;���.���V����PA���D
�H��c4�F����*�E}y��Uw'�k��O5#�:g5.<��T.Rt7ˣ��@�]��JW��~/�Z=�]ghZ��3I&y�EwUۖjY��E]��#��a�I��m{�F��8��ɔ��ت�;��*N���@���N3֘��˩�����V���9r��B?^ձR���|ӿ��R�r~f��g�$2}���0;R���ԕ��>q}68����I9�CN�2���F�{�ީ��	|F�?����x,�}��iQtZʵڮ��t4p�+�����[X�[�¶��]U��U����ȅ�4�/�n
C�w��Q�ĕ!�	�|�&�(���2���[IS�z��핈�N�;H�L�d�QA>�����;��ڗF�+c�n��EPǻu�p�,��a-l�1�i�0��N》����x�8��!�y��e>�B���vs�e�ix)�����:f��$�>�5��E��t��v�t1uBxr³)�l��yFr�d>�s�6�Ƙ�0j�Yx�"��b�{�U��u2)��)���p�o4I�������yS��~	|������itss�/)ޤ      ?      x������ � �      7   �   x�=�I
1��u�)r1�.�F]i�M�H*M��h<G.�����5�����v�8�Α����E�6��Q]c�6���?Շ(�p	;_��%�Bg�2��O�x�y�@_�#���k8p.$�q'�[��p6��o�a_�\&��ѫ<�      =   �   x�e�An�@EמS��� mYV�� !U]�1��F"�`'n�X��A.�PZ	�ƒ�޷~K1��D� s9���=��8�|�-��>�~�dk��`$��2��(nKҒbs���׈��h-�!wO�����}�3�����v���jRBe���&��j�R��w�|t?Uh�f0�����+���`5��Ү�=]5�)��U�9w3SE      r      x������ � �      t      x������ � �      v      x������ � �      p      x������ � �      9   *   x�3�tt���4�2�t��rq�s<�~��(f����� �      ;      x�3�4�4����� �[      (      x��]�n$�q>�>Ec��k���Er��r3� C�"�8��Mw�W��u��'��o��>�~��#��]Qٜ��3K1����"2~2�`"��
�V��G`�P6Ny%��1�����r�庛��W|��f�������o&j�H�d#��L.�>^�M��6��
h���8����	aE�1,OXjK�;B��4B��حV��������c0�K��!�?��R*c�S�0�a8�4��*>Nڻ�u��}u2a�-�A�V�U��+����l��i%�m��vW�p��T+��
��E>K�p|�6V)����$-���+��B��eO/B�ײ��"�D;'d&��㋣��@�C4y{��h�=��F]���qE���ŧ���zN����������ӫ�<2�ʁbJ��'G� ��|?t�9=����ˑY>r�^h�ul�'axi������F8a�i\t?vӫ�⾽_�߷�����᯷��t���vz��oN���e@���sD��%�?��r�n/��:`~�@S
$i�dқ�]|sj�!N������T`9�Z� i��?�u6�Z�@��5�n�&������ܴ��7Mlua*�H�#I�e�c~�?�Y~z�\�O�����7�&�MC42;���V��04YG�uD}+ �f�#����[HF���]/��nz�\-���ڬ������ߏ.Bx�R��h]d���IA�.[!�4��[_��w���"�k��[�8u$�A��U3^}������]w@��O����������v���Ϝ�N���'H�勾�=s0�$���Z���D��O��F��r ��i��$�S��owѮۛ*�B�z��ziE�:��Ux�O��SK�SE�	��x�U$��|�j�5��NaaWw���Pl���XBp�Z�~�Ǯ����b~�~�~�]��IA�������{�on�O�mz�IJ��6HAu$I����爔q;�p����v�>��f�R�Ld���ٶ�������o���n5E8�ը9m�H�m]GW b�Ly�ȑV��ָ:��x�Y-�C��l�����9�F�Z%&Ə��:����4�{�����ĈנV"�im�C)��y/��[�äȡ�Z�C�_LCԎҞA���e��.��
������T�h�)-�Iګ/�$]A��ݓ���b*(N�aH
�Qt�6@*�^ye\'"����Z�k�85?@�!0j�)�i���8nE����#�%i��h�L��:Ǿ���p9���O��8|�^v��_o�����,_�l�*8.]��u;[����@�IE)��q_.}�4A:���|���r�ʦ�Q"�1F`
;�c9�\��N���OI�!��~c�yb�z��13�X�\���K��ƞ|��AzgT
��Z���S{�fA�^1"�5���A:�T��l�����nu�-��ˏ���&�a��&^=�ps
��u9���X�sf�t�-��Ng�{o��oF��a�eP�~��pw��[��WU(͡�,=fO����@��t�N緛�|��F�G�pDک�4���2�����Mw�NW�b<z�@�B�)���R����;������3��H069I&_OEK�a�T��7�����ᮈ��5 +8��q�� �F���MX��]�
��}�o/b�)���h�K�zݮ�kd��x�uAK;�ʏDh�v��mt�|Кժ��WLq4!���o"���J5A��Ջ�/�綒���ChK��5���?�y���ϸKr�Ev7�L�c)�>uӧK��3�Y��C
��u���R�=��R,��L�u�K�e�����l���8��C��Gal�
��x�9�`�E����dy^���	u�C�~�T�J6���[�=�u���@p�G�6(�Kv���~-<oo�<]DU5�s��y�05��χ�j��� �d?ۇ?<ݭ����c�t�S#�v/�8[�i.����r�?�;�}b��%��-yi]�,Ś�?�k%��fv�׭ q���@��kui:��X�nm��>E�@����eyd��t�||�a?�[���ZGs�sy���.7ӯUp|JZ�v*0�ˌ̋LC�aB�N)ҙ^���}Kq�!�q�Ǵp�U(�*�'�*QB9I����ݯ
���=����XrN�i�ǩ&AE� �n�5m���
�9�&x�iEk`��檂\}�(���)�uѮ���%ޗ�e��)�8�rVKM>=������b!S���Ez ��IEkQ�l6)��;xc�k���	�O0)�N$M�<������-�D�����g=�����������N�Ŕ�����l遱"���%�<	L�+SUd:̧n@&s��P��W��Ȥm,/�9L���{%��D)C$��)S�
�)_,����_L�O�>~<�~8{���Ňw�ӳ��ǋ��w�???���ر�<��Cڠ�� ������w߽���ͻ��7��݈|O�3Y�����䟿�x���7�{d��l�0��B��$��99��k���H)m*D����9=>=�?9 �������3��g
>��C�&c\k0�
�0i�~����ś�뒇�MژA�s8<9>���yP&R�#@���^I�"|��sp�v�׫��n���h�ah�P	��bS�;��>��je���c,T1�z!;�d�oِSo�{6zr�ho���[�#yV.�w��ʧ$�Q|�*���x)^0���v���6�y���e1*�]m��P�����>^�q|<����z6Z�b�����d��xW�ו���� ����xS�6;熏7��
�@ٔ�֜|� ����K��ɧ��
����=М|� V��r*g�.؇��s"�?g�.؇�I�!�g�.؇�I�I���S���?)uz~���
�a�ur��*���I���+�?U�+��|%w��O��
�$i@4^��O��
��)ˤ8�T�?U��B��;�*��*�{d���S�T�9�R��������b'��S�����q�aA?U�������S���	 ��Â~�B?�F����~X�OU�F���~X�OU臶�9������)"L�����|>)�ه�t�}JȤ��ه�t�}���t0��O���)
PR���O���)�oR.��O���)e�}��'��
����&��,�+�SƤ�����t�~ʪ|���O�3�)�ofHN?Y��T�G�kڽ$�,�g*���������L�~|�	 �~P��T觥O5?��~�B?����~P��T觕u)���~�B?����>(�g*��!�s�A�>Sa��6��>(�g+�W�s�l|�>[a��Z��_��V�g�N'���
��
�m2�Ň���
���)r��+�g+�3��O����x�B��m�GCX�U����hi�H�2�+������bt�s�"�|P�mX�Ѯ¸p7#����)W�f�7���R�fd�xx��|�[�4�ڦ��1��S��{����p�p������Ѻ-#]BP"�tkG��xA����Vn�2�����[F@�3y'��W�k'���O�b����� �� ]�U�ae � ����2�\,�% �bА6>�Y�)3��sV@� ���"���b�U9��1�w��!��q1x��n�-�,{ �|�[1 (�����b ������箆 �$���K��_kND]Q�
=��iNDmK�
�R�O_1 ST��u>گ9�.*D�F��+6^��+D�!��X K�
��T֜�Z� "���), %���'��Q�`�� ���<T�?��0���Ob1���0��  ��X��!���	�tUq���0�� B���b %a���|q�Y�$"�1 xt6g�@ID#" D�SY�$"�1 P�+s.��D䕐 u
�'�*��K!��Z��YC ,��k!��b��Y�d"/�d �,r&b�D^� &��@�D,���!��*�SZ�d"/�� ��9-P2��D2�s)����X2�E2 y8��Z�d"��$ �T�&g"�L� +  e�@��̉-P2��E2@_ԓ���d"/�d �[lx�C^�ÕNN��<�%ya$h��wpʒ��2�L��%�,y�K#�*�'�@�C^� ��,9e�C^� ^��@��P�<�Ց���>�@�C^� ��ʜ�b %y}$Ю�s�k %y����Ι%y�$`����P2��H2��� 8�d"��d �+���%y�$��3g"�L�e�`uNr&B�D^'� .���D����N��{�Su��P�J��QND(��+% r�!/���d����𒄼N��#$��s�� /���p�|����*- ��e�u9�B?�}��Μ�rt�{�<]���v�rx�y�Zӷ��rx�x*ߊ�]9z�uR5��t2�X�:?}kC�,��}��o�5��yO� �ŶO��K������N�� zО&��e�N�n���L(R���J�Cg�rv�3�s�*�%�6:L� anT>��'۶��f�D�-��#�v)�&k�CC-g��P�ۡHn`8��h�!.���*�YC""-N8B�hM> Q��tzɴG8��c>���[�U���&krб�B�C@#J���8�)��]=�	zBƩ�艣�rP��АMx䵟�٤�:�y1�t��e�d/Ź��(NeÉ�@���8ݟ��+��I:ŀb�З�Eq��?��(.d�s4 XX/^zʀ�y*�E�V4œ��s�t`ESH'ҁ8���|�rz�kVPB��I�5؆�#�[��B���:VD�*(rGS(h�n0C+L�ȼ��:ӇY���|^_�%���e^�ʀ*�����殦h�%^EQ�鐞,�YOt�����BX�"w��Q2ih���E��Qڮ9��!���(
9^���-k�7h����i��%k��]>kQ*
�G$t1��� Wz%.�������#�U�" ش����B	CW��+�E<�w����0آ�۠�	��	����2��˖�!im�x�j:���'�k��C��T9�q=1B�ä��'�[�7eU�f�H�J��?I��Ma��jv���ܺ�����n�Ar�K�0VxN�|����.����l�o\ILn�iJ�pF��(_oMA|���B���nT��.������X�/��p)��}���.�*���|9dW}�0�S�v8V	�x��&g�(�	��9�}Ӵ��r���Nx8�A�V��βall�=(��p_�tLA>ֲs��[2?�������~��]�Oo����=TC���P��ֆ�x\;�b{R��]'��}8=;?~���}G}�������F��ty�����Eh���V�q�@�*��+t�0?z+��>�`GX�**��Èn��aFq�G��&�P�_�X�ՓY� ������k��g���L*/���M��i��b�cۭ�/���A�����1��x���}��24չ�6.²j�.�^Ȓ<=�Ԑ�����Cn�cY��(0�j
zrYL�]v�=�����(��Q��?��mn��*�`�NF��^�ʊ��w��^�+��,�� 
�4��|�Klm�]�u�	3��u��Ju	���d��_����X�[��0�������Ժx�[\oE���\t���n��æ��i��*6R�y;_��j!�EWƮ��.±lL���[?�E�]���\�
��]�m|�Sh�Nw]�m�g]�<�8;?}C?�xW�ъEaX�4����.�ůos���\�̯�ԨΦ�pY4@�������Dm�����BsP|dɤ!o/;��9����s�|�m|4&�f���fa�,����U��D���`����L@j��次��B�p|�}�p*T�X�:�':g0����
�����-�B:�zB�J٥�	b^t7�5��,,|�����#Q!��%�q`����5��j��5�=э�I�B�H�@ee�488={���?��
����d� ��M���=O����ޚ���A�סyB����N-��:p�ࠬېpF��M����� �|�A`.����dl�I���`���J�ϥ�08��O=YС}0αC�VR�L<=V�c�����~��>�o�:�}7���zzҮ~lo~x�������jy����):M��هǙ��46Hs_�Q?���1v��n�Ǽ^m��2zy<:E�￘��.4ͭK���#��㉊G\bm���\�ɟ��!3�;�}%ao���w����E�H|<��cS��	߰�x,_����cP�C�9��R
�}����*S"��f^=����@W�aY�aUh����R�|W#���A�rC`?��i�r�֭h�k��}�����>}��Z��k�� ��xl�̎糁a?�@�N����C`\e��ojzK�K�PԽ!볟�#K�q��þ�H�T$�w��y� ��ӿ�x��q�� 2�̗��뮹�������i%{��v����hn�����P�k$�S�?���߷��i��k���ZZg��_����=�b@������ɛ㱞<��ѻ���C�
���3�s	aB�a_�ҍ��0
 }�@����[2>�ﻛ����� ��U���Jէ������'X�����\��J��ٟ���>���e�{�
1������$�&A������������V�մ�ݶ��[�Yn>��Fذ3z������͒1\�Y��=���y,�C	.|,�3��Nnj��g�>�a��ڣLu,����v�����]�ڃ��0%���������ps���`|���Š������u{���ǟ����[2�9<2����[��V��4a��c��#�*�*�>�݁Ty������p1CU��M��STy��~���6mE?�4�x�:+�?I
1������C�&|iMg�+d�$W~�lV��r�`���B���ɗ>�B1&a�ԡT������ƃc�;jj )CkB���������3���5��Y���t���C�r&��9�p� ��,�|	�m�>�*��k(,U}�k�ln��߮�!� �c��:����~�|��7�k�.�         C  x�uR�n� |f?�*8�T�6��A��N�~}�!G���b�23����HA�F�$g�({�lc��2c�S�MS���c�"�9?�)�Uͷ�W���~�P$�t�g8Vأ��̳ORt���Vfк�x��r ��Tr�L���ء�0��T�-_j���b5��U���K�eú2m_����c�ͺn��3����ɹ/Ք�L0�us�ov$+o�)�O��t�b�����rW)�������RZ�/���E�	��`v���X��כ�D������b��Q�.��}>^7����0�+�J�f	%}�����O�=(�x�_����         /  x����n7@����{�s�m�� �H[��UW�4��wH�#튮F ���3�a�i;���4Mo���d���?�������wC�ѭ��,t֯�s���|ç����"��.�����ϐ�6�|F��`:ϲ��-��q��'YH�ݮ��/��[��,m��~8����sھ��$��2�ݸ�d��^��H�7�9��H.2p�5{�6��ӹ���%�(������Y�U3��E�P���7�çQ�s��Q�>J�Q�3���#��`4���q�\����|��}�`�l��Fq�ݿ_�����=�}�!C	r��_��ks��6�0^����8���_.������4\hf�4�l�ԍ�F�9�R(�����\C=�����aB����0�^ϒ�>����۝��m�������W���뤋.�9�5��At	<�v�#�KG)ʱ�|U��-��e�Q�9/�Mڒ�Rm
�#l�0GE$D�yA#pl�Q�\�Ii;�m����N��_��vK�k�lW�*��Ц=[i�tx�	���}���^Ḅɴ��1 Ԕ�w:�ɂfj������%��@�]�#�IM|�m;i>�sRՀ�4�k�太/h�!��dj�#5����c,��i�4<�S��끑�>����^���݂��HuM�t����^�̯��s1}�`�O\A��u��r�:�ͭ��1��Ф��P�P��,`�ĭ�ɬt2l���ǪB��U�v����)���e�w�����#����O2	��Ɯ�d�`���3?	 ��%7��w@kG������M�M[|��U1������t�@5y��\2���~����v��v���8�B��te� S�S�j�g��r}�a9A_��a��!��+�΄�L�R�E=V�0.ikL���ח~̱���p�1Z&���(��Ъ��C��;��2�* ���ҫ�r�FSـ��Ȭ(Wdپ�����cs�M��p��[���6G��̖�����P�x�(ʍ}(�[��pA#�eb.r�7�!��U��fpH� �I#�d]Z�#~�y�4�ƍ\��٢�U�h潴 �I�fU��Cy��=ʥ�YU�܌^Tb�d;��)ȁם�r䗴��hN[C�5V��ǆU��������r��Z�l� �n��ė&��ئ�ES2��Y��M[��y���L�<��vn4���Y:ٓ���J�"�I�#��4L/�xy;���t�Ey̧'<ɽZ_FN�cJ[)��S� S�$�R��x�V�vR9��h���S���=��`?�[��ц:V8���d���\.�y>_�P5u�u* ��_[M��Pr* �ҩ��^��Hr&���#�v}285�g��\�d�t��?��q|������t}�z�ϊ~糤<��
Y��o�|c��j�x��:{o��G�̸܆)p�Z��Y��N��+�$`-�.mګr�`M�v���k�a׆��r5�*���t{�����U4�����-�VX������f#R�ֽ�eC�	*%�քe&v�=����� �i����A�r��6�����GR�,h��+�y�$����o�����8      R      x��}Yoɱ�s�W�}����ྔ5�A��C�K�U�Ծ毟�*�����8�C�2D��Ï�|�E�2������$�n�.�![�������ku}����~{|�^��Q�]Y�<}�߾���=%���	��WxwwzS���S˿Y�����ý���<z�^}���_�����/e���f#���y���j��-c�������}���N��������^��[�~7���;Ml�W��~��ﳄ	�c�*�������f�.���]]�+�^����������}yz1w����w���כ��}������_��3dX>Py��`D� BfTm�pj�~��q�B1�'��c�nɉ]��?#�����9;vcJ�xW;�2Ґ�m�df�8A=����;�����8`���M8�ƀMv�j`B�]�XZڞ�}��<@za�"v�K�y� 3�`��Dl��·��N�v�����0�(��%�\�����YW�TV4�R�,���=�y����p�$ń�T�W��[����yʦ8���h�v������*���wr},͋���ٛ�nW�b����Ӏ���}{�����n����o����L�V����>ѫ�
n_^��c�O����{�#7w�n�����]�`v�] �.[il�tUXPg%�����!������c��=��^������/OzQ߷�Wx����S�^ݏ���������u��s���~�nO��>}��=������x�r+o.X���/��M}Vw���>��rYR�{�ũ�x!-�J��$�xB�Q5�,�#N�}�N>x�#��@�E��-Y3����a����V ��'v?��$P8��T���l�D衞0���<oX3z8}�;O�|��
&�nw(Ze9�HoS��6�Z�rȐ!���v�]�� CxǮ[�YZT��r�h��\k\64�g�ݱc���r�b����$����&k�t����v^ٹI����O�B��{��kh�&���R�H\�*��A��`��ՙ+ް�v�\!	g;�#��@�(�B��d���W��٭��O��|V> ��@ ڱ����&��2 &8X�4Y�{��
5�O\8!pwF�3!��葻-QڒLc���O�{���	��©G�S7�l�d^y��Ml�JV�E�:���e}�#{טa,��FI{T-�FB�����2�4_&�F�/w���ޞ=�{z��x������L��ʗ/?<�����ӧ����_��7��=&���Wrv��u�?����/O���'�ޞ~ߗ��� W�}�6
��(z@��8x�n�K&S�f6.�f84��iӪ�z<}��gC-�ɋ�3��p�O���V�,�h�C�c-'�By�ݎ�3����b/+m�~4fFLtJ�e(5m_%kGAZ�%َ��~@�����@���Y�kZ��$��B�Ħwж��}�;_΢P�.���Փ�f�rlima�8�Ö��w{��w�-ȅ�j��fGyFrLmR�����G��"9������� ���y�,T���?D{�[�Yd�I��}�ec�K-�.����9`|lC� �D
�g�$�gP�@��$���&N�-�����rF�����쎠���e;kU�:���(�R��e�9�B՝��w�����)���#Ck��C�f�y�@�;]u��N�v�HHA�sg��b!���X���Z��iM�����v ���}��C�����8�Y����X�n2ͬ���G�.�9��+v�����d ���R.Y�r�-6-s7���H�.�D�%�f��=����@ 0����y�g��l�9�`�$�QY�f��d>+��D�'��.� w����(�C�DHՔk�r XG��isb�cG��ݱ ��e�1��k3Q�VY5ʵb�H�ID�J�Ps
yv�|I�#<����,]SR��g8��Ze�z�G�'K",[�=~�߾�8��������屺*�g�!�~�g��/�z���3�O�w��7�i��;🭺���ǿ��+���r�r�W������|�.�����1�A�������;Y�8r�)�4k�<�U���7
�˴%řgw�Pl:�F��"ObMJ_���x��GED��%I���ٷއ��B��r��Jn)La�g}AʴJ�$6�P�`�'G�ق� �$���bՁ��ꔓr���$���:d?�{k���pQ@��`��_06�c[CZ5}�o���v��.�!!W L ���X��vB��fIlD�EQ@��<;�;�`���/�W1�Uj���\)�|�X�/6`華���nw|�� /&w~7�v#���5h˦Em���Ǖ���_|A�}���|���O�v�+����9���]�����;
����}�_c��yV�?��ߴ�3��x'���篞'��巧����'w�����Y{;p�X�A�@��"�{�pT���|� ��d�Qg<cF#��)�|��0%#��c;tGi�A ��J��9YuI��,G't;5�1\�L���Jʚ��[8o��KW�6J�����5U���NphA�c\��"���U���U����F:�d9�g��9a�,�+|��ˢ���L���4���X#��P�	r}����8�����('�=�Kd��~�85y��F������L��e����ٺ�ۚ�U3�`r:)�W�YN�N���=��'=h��a �>�0�H���h�0�4�lZ��C
�>��,ܻ(0��p �5.�,�vK��gP�EN�-b*�S��������ȅP��t�	;�[�U��A?���6f&�ASwv�wzG���]c�
�O�V0�UfR���;�.�P�[ݧͬ�N!�{J��"�;�!<�qϧ�m�D<��
=�"&ɶ � ������Y
."|\��֪I榌��(�LDY9� ��"���y�����w�>�xttRu�4�T	'jsx(g����S��޽C�E�������y�G[I&��	5�PVn=�qgj�;�
�0�p�({�[k�Tc��T��y�uô�)�h��/!��<�����vw{�?��q>o=���|n_^����~��o�S����<�9yQ�����o����o�r�9A�o�������m�~����c�c����)�ر#����QGb%�2�/m�hN@s��~v>=v4�CI@%�}V=�J���^C
6�,c�Jr�9���N�u�5@�'*��a��J��f�{�}�T�ju�ݫ�1O�(���dR�s=��<7C=�}ޏ=�	�+��������=@_��U@��LQ��1E+7'�s!�pb��r'!W ��
D�p'�,�ش�
��Z���&�{R���avb_��u���#D��f<���5��K����.b����M�C�>"�� t�
@�G�gZ����0Y���쇊,����c	:��Y�-�h�5��%� 2��l٣��	>��[U���^0����
�6Ŷ�|���OLD+K�	��//�_��WW�����?����*�<���oޕo��3�?�o_>���?�"�Dw�/�W檌~y�.w_y��˗���]�>��o�_>!����W]�yv��a�U�X2�,���"�U�v���zj�>Tx��I�84������\bY�brP�g�V�:t|6��p�H\0��h�ػi�@E]��sIG�Ƨډ�yIι�b�Y/q�����0�3����汃��#��؂j)�鲻݁}X�#���mrO�Z���Jm�I
2�ҵ���SYsqg?�xh�QN�Q��c6�,˖��94�����%�X�N���n�y��0��q���r���j��[Q9�=I6e婁�YUrY��Ӭn�"�Y4�[/X�ՌYd3v�>2R�@��ۜ3�-�H"'i��:�$oLR���)��B�=_��~G��g�����Û�͇��vW>�;_8���_�ݿ���Wtw�g�)���]{F�RzV�v��>��,=�r�N�'��?m��b6�w>����:�y,�)�0��R�|Q��ᐝ}��� �{,�p��q�����V7UJ]    ��\�jɬ����e���"~U-"	����Ȼ���V��M�M�Ѝ8v^�~?����'H%a�`wKV9
8|(k��K�t��4K�T�:�	��h?�����/�i붴�\�5Qɲ�C����GNN�{��DH����B��Y�`iɄsd	YrOKP&s���pV�O�<�g`�f����4#��ªn�1�e�Jh�ˋ�/����A�M�(�(�w����}{���1U/O������������(�[`���h�g��
�>m��oϿ��3�������;S����<p����f�,-��z�|�E��2�q��L�&�����rY��+�BƎ�(m��׃Q1b�Cz�*3�(&5���g' C߅"9E6%)������ �t��J̙NO�۫Y�*	���$t�wɸ�5`X��je�d9`�b�lK���чew
�F�݇��5� ������yZ1�x��n��M.:P$
@"�Kܡ2�j\�Y.���b�v6�h�j,�9=�{0����Z�����K6�m-��h�XF"��Dx�"TU'�{oA�w�/2��\�D�':��I��͢��	R0�z�y|���pv��<+�b��֥C�2�<�(��ZC�ZL�}���,�
J(���SK��.F�xY�M�k#�\:��7�L�g�3h�A&��gөIe"����3�ł���k�M�9���»`D���{���%�'�1��)A���\�{룄�OOS<GaT���S&-��t(�7�5u�4�*�8��&C�j�0& �편2���D�¾�Q\޶�A������o�����>����"���ip=�'M��Ǎ���&�?���G���җ/�����
]��^���_Ä�P����HM���|ߞ���i��x������,���yk��g��#�q��RL%��Nm�iw?�
���,���ج�G[��9[E�Es���A���ē9�wA�P��P�}cm�9�k"�"̢���O)i�F��<�&�����s^�n}Y^6��l�hJ5k���4�8o�,3F�� �xZKQ�b[��Į��D��2��\٣鴻3F��[F=ǋ��T=v��̒�Mu����u�U�T}��+h��dG<�v�d�!��r�#k��Zo�bipr�W���(/1p��7@�D)@K!&;��uLbćtj�Y�}� �֢��(4�)D�G:t���VV#Q������� ���_o������ْ�떹���W�s��K�;���
��׳]cR�mv�+�,k֭�^�9�M%�<ө#��n�N���S =tP�HCa�[>��XܼD�E��4;���z)�K��{Z�
J9dx�fR@���2j0����泡��]$ ��w�P%]��Γ�P#Vu��)�k��W��<��8
� F���v7OZ����iu��key��`����&�A�� ����DMU�Myi73;<O��ס���7��!C�<�<�:��Dk1S�N�ϋ5�#�Q<��b�{�= �(~�Y��4����U�)�Ķ������4������o/ y��BӢ�y��6_��j�1�~\t���4�X��cs�{��[]�(���2���,C����j�fktz�[# �W+0�@(�1`L-rT�6.�Z��:iA���1�ى�N�eX���w��7\������"�m��Y�����������%h�{��6)�D�4��Zgf�`����x�&�{# �]��:�'��R�t^�@,6rp�ƧYw=:s�ϗF@%=�;��(Mҡ6�Mc�2b5)����&����s� �Q�r^��� �n�*�&���avb�7�gqh@IF__���'5IN�\Q�+�A�i�9 y�2x.��	�����\��"�Z�-����HjbV�ʰ���yU��N�w����)�G㳘	��b�L�'{� ps����l@�0$C�H��lU�2�n�j�=Z�LV�6Z�`���Al�����<;e�"-&24�J��u�tbY�0��|��]���
��t���p�W,u�K��<M��cEJ:mS%�`��&g�H��z�p�Y�,̘(��m哜Y>.s��0��t^�{�;�#�Xx�6�R4��\1� ��b_�m�Ldz
f�xG�#�!�a,�L��պi�$z��$i�u��zZ|�e�B�?�ؾy�/�����O4��WR�"�)7����}����f�8,�t���"nj9%�Z�(�	�8+��j���C�̢$AB��>G��X�@W�Q�۲���Q����<��Vφ�����qha�IW�e�h�M���M.L4��[�O��[MFph_��el^lE�G��.�+K�
(7!��4�`��Q> ��!�m�5jBp��(�K��[ͻ5�Y��>���6"��b�U%#U*�-��:+��������V��y�� �w��H��+�ʍ(�Z��mU����	��Ԣ�o�^ϒ��.%=��S���ʮ|S<�"�g�骘�R.N��k%�\�AQA F�Q���Ү �Rgs���P��n[\����C{�� ��(rI44���W��+ns��r�U�A�rbw����w9��8���:��hG!�t	�g �X7���q��v��5� /�R��, }V�,��u`�����q)�l|^�}o�b� %�Ϛ�OƑu47��zˊ*��U���|����
@ �+� ��n�۞Ɠq�6a���S�2Z�<d������~�=0<t��Y�@ó$��P�\-��K:Х�(����&
Eϥ`,w얺X]�	CV:�&_x��,��:S����&JP-zû.�AI�f�Ya7�Y_�W��1?��;1F������B��+ݛ�+�Եۆ�����q���y	�c�����������E,�V��+P�L$��\�%b��>�����L[ J�,��m�TZM��Эl�t�*����\��.}�]E(?.8�6�e\w�˵��J)��^�s=ཨ@���B� G㓸�T�$�b�� 0�@������GoU�k���ý���o��i�5�Qϒ�5b]XR����;�{�*�CА����h�hQ�H��z���*ROZ����/6Ά�+�C�ֱ�w�S�v��VaC=5��
X7�l鲵l[�T����������6��x���m�z�״�
_S�,k�u����Ry��7�����J�T�&�h�VM�)��VLI-+��y�a�HdV ������l=u�0�̪&�c��)*�sb���d24�%���Bm���*6	)��
�%o��M��\xo��$�U&|�8^��q����R4��4��,�1�W���|A�cM&��ZR`~t�Y�o1*Z�y�$�����:r=��廏5�
�?��n�Ș�QIS%8ʆU�C�<�Fr{��?��P8�xL�^���rSY�v6֐~͉k�I�4!���&�x��"8�j��4��5���i�^ҤMAO�9�~��y��"�,��:ma:��De�MJ�l�Eٔi�a.I۝���Q�م�Yz���C/�Z�C�Aײ�r�n�������F'5~o�}?�\��oo`�+��ns�����t�6�f^��N�ݩ�ނ"|׏	��O�2'������,ֺ����Y�����#�Q򪁚���RT�dj��<fĨm�M�7*>�Q�T^ ����N�KmT�9"�⹙�5�<���E�'5~+gE!��\ G�W �⡝(JP���b|�E�f���r�p���;�/�S@�x�E@SH���h����e����9�O���Q�~�rvLX��xpdUm�DK�&I���"��!�w�"��6����vK����Q٧6��k'�l����f��k���'ů"�T����4�Z��TV[�qQ;��}qB��"(H|A����qR[S9��;�Y�2��u1p���?��Ȱ7;o_�s�)\G�*�O���V�-{�pK7z��}o|��?qĥ8�,�H��c[��ͺ���{
���}r|�݅�,���S,��6 �A�f��B�|�!��mc�3ܽ��q�S _ -	  �r�>�a,�j��&M�-�u�m��peqR��\�{�{�]�/q��p�e��:�,bF�fK#&�X�LŦp����{�E*�����U/;�H��LJI˭.��%�!���xЏ^%�>+Ş+r��a� `�m��y�L�	�V�ޞ�'W����Ǜ��?ʻ����	�X�={,݋������E��ҡ�p��b�g}��^��������?���w���9���>���u{*��k���⁀�����9�Eۚ��Uk�!)�\ڭ��3Ͼ6>Ó�ၨ�$>޽�Z�,9I�M��m�,���l�а�|i��P �_^��HF��]97�"Ӯ$�S_��Yr��+9���5��!(�>ɂ�F������|J�����6�s)r(�6�:���yrP�*�Ѽ�-h���K�8�-&\��0�4���7&��~��C��b�!�J�$M95�� ����Ky/gEh�Qv���=�	բ�����fjon�H(S�e�jٞ>���S� s� ���]��B͑�d��@�|��1��n<ⰱr�do񎄗S!�@�	�{U_�R���
��,$��.iQ�f{�ݎ�;��AA	9�,���l0�j�.����f�k���>��G=(py\��:�Iv��V(ӛy�K[U��]���a�=�퇍�B&:�d�u&cƹ� 2S����_�ѱ:��Ϛ�>K%�k�e#�e[�xlP�(�������M*sb�:%;�w��1b��(��E'd�Z;#V�)3�j�Cb�_^�w�������WwJ���_���p޶񋺢�?��}rwuG�%�۳����}����ߴ���x'�G�ٟ������;�\~{�l^�|r��O�Y����1�B���� _�Ok�WK��C��^�P ���b+�=�w�,�ⲯ�;�,)���c
�.�(ˌQnzp�}˳��� վp@�1�aK���'��P5q7���G�Q+��^�;��`r��V�&�L�d��m��%��Q/3�q���1� hЏy�B��fS���Y�k�׉�L[#�h-�I��4��n���!x]�Ky��Ynɔ	g�� �e�K�S�:�-�;쎄�;N��R2%��.�b�4�M�E7�~R-%���Z���Z�B1At�(�-궑�q��)�&EB��LMzj��UP�#��"|���i���^ӏ�SY��Nwq�:��ѩ5~k��w|_;���V�\4�s�R`�N�2Jm��r�J7�SA�N��#o/�c�}�����A��]��	��h) �P����"�"��n���eԙ��ul'W&�PG�>�I.�iv3��G8ll.G�LWc��P��,��x�K�L�`.O��[��H��_$��XKa��&�L	�%���p�!��ek۩:�{�i���%�0�a�S�d���1+�V��Z�4z�� ɉ�[Y���p��Sz<�ѕ���U!��^���Wk�)�nsy��}�wh.\8�ǐ,��G1��q��]�Y��A�U���Nf��f�.\��8<D���(H��Z�M)&V Z9���ύ�wvrl8f$$���P���Z64%rMk`���F �]��8�� r� ]1>�U�/��m5h
�S�4�yE���ܦP����w�g� J�!����:o��,��z�2�i�U6�g�xV�+$P��8�m����8�6��YUk �>j��Eg�����x��	H�q�n�-:E��TF���Ʉ*snξѻp�Q a�y�;���ĉ~�骩�r�'���pb�c'__����0G|ϳ���Iz�5U��\ۥ��uޕ��)�}����Z| �B��"^�ˤsU^mg��D1���9�O�۱�'=�{�S�Q�s�#Z�5��x*�M�<S�
�贻�<K�Am�.�ce�D���u"�Ux��0��Z��4��FN-�+�ۯ��,�iv�/K�ُ��),hS�嚭`��s�����;r<�#�y��
8M�����~[A��CUV� !l�h�w�.��|M�G;k�����u�L2,]�)��2�9���P0	�  rTd[Β&gQ'rJ�2����J�ªk����;8B�B�dvk��:��i�0���j�`��U?}��{�("ȴ�d��S�p��&0ici��B�4���bE�9����(
U����g��B3��¨�n���Fr�d��V��;�g���g��V��d�� k�l)��怊�2X����ޡ}u\�w�c����Y��-�[�f[b閶Q�H��g�t�@�`F���\ѝ^����:>����G�^Qh��'A��?-7{��Uw�c�y(_������_��wWl��{*�����d��T%} �u��F�����O����s     