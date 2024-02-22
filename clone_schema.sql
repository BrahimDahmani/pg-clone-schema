-- Change History: 
-- 2021-03-03  MJV FIX: Fixed population of tables with rows section. "buffer" variable was not initialized correctly. Used new variable, tblname, to fix it.
-- 2021-03-03  MJV FIX: Fixed Issue#34  where user-defined types in declare section of functions caused runtime errors.
-- 2021-03-04  MJV FIX: Fixed Issue#35  where privileges for functions were not being set correctly causing the program to bomb and giving privileges to other users that should not have gotten them.
-- 2021-03-05  MJV FIX: Fixed Issue#36  Fixed table and other object permissions
-- 2021-03-05  MJV FIX: Fixed Issue#37  Fixed function grants again for case where parameters have default values.
-- 2021-03-08  MJV FIX: Fixed Issue#38  fixed issue where source schema specified for executed trigger function action
-- 2021-03-08  MJV FIX: Fixed Issue#39  Add warnings for table columns that are user-defined since the probably refer back to the source schema!  No fix for it at this time.
-- 2021-03-09  MJV FIX: Fixed Issue#40  Rewrote trigger SQL instead to simply things for all cases
-- 2021-03-19  MJV FIX: Fixed Issue#39  Added new function to generate table ddl instead of using the CREATE TABLE LIKE statement only for use cases with user-defined column datatypes.
-- 2021-04-02  MJV FIX: Fixed Issue#43  Fixed views case where view was created successfully in target schema, but referenced table was not.
-- 2021-06-30  MJV FIX: Fixed Issue#46  Invalid record reference, tbl_ddl.  Changed to tbl_dcl in PRIVS section.
-- 2021-06-30  MJV FIX: Fixed Issue#46  Invalid record reference, tbl_ddl.  Changed to tbl_dcl in PRIVS section. Thanks to dpmillerau for this fix.
-- 2021-07-21  MJV FIX: Fixed Issue#47  Fixed resetting search path to what it was before.  Thanks to dpmillerau for this fix.
-- 2022-03-01  MJV FIX: Fixed Issue#61  Fixed more search_path problems. Modified get_table_ddl() to hard code search_path to public. Using set_config() for empty string instead of trying to set empty string directly and incorrectly.
-- 2022-03-01  MJV FIX: Fixed Issue#62  Added comments for indexes only (Thanks to @guignonv).  Still need to add comments for other objects.
-- 2022-03-24  MJV FIX: Fixed Issue#63  Use last used value for sequence not the start value
-- 2022-03-24  MJV FIX: Fixed Issue#59  Implement Rules
-- 2022-03-26  MJV FIX: Fixed Issue#65  Check column availability in selecting query to use for pg_proc table.  Also do some explicit datatype mappings for certain aggregate functions.  Also fixed inheritance derived tables.
-- 2022-03-31  MJV FIX: Fixed Issue#66  Implement Security Policies for RLS
-- 2022-04-02  MJV FIX: Fixed Issue#62  Fixed all comments and reworked the way we generate index comments by @guignonv
-- 2022-04-02  MJV FIX: Fixed Issue#67  Reworked get_table_ddl() so we are not dependent on outside function, pg_get_tabledef().
-- 2022-04-02  MJV FIX: Fixed Issue#42  Fixed copying rows logic with exception of tables with user-defined datatypes in them that have to be done manually, documented in README.
-- 2022-05-01  MJV FIX: Fixed Issue#53  Applied coding style fixes, using pgFormatter as basis for SQL.
-- 2022-05-02  MJV FIX: Fixed Issue#72  Remove original schema references from materialized view definition
-- 2022-05-14  MJV FIX: Fixed Issue#73  Fix dependency order for views depending on other views. Also removed duplicate comment logic for views.
-- 2022-06-12  MJV FIX: Fixed Issue#74  Change comments ddl from source_scshema to dest_schema. Policies fix using quote_literal(d.description) instead of hard-coded ticks and escape ticks.
-- 2022-06-13  MJV FIX: Fixed Issue#75  Rows were not being copied correctly for parents.  Needed to move copy rows logic to end, after all DDL is done.
-- 2022-06-15  MJV FIX: Fixed Issue#76  RLS is not being enabled for cloned tables.  Enable it right after the policy for the table is created
-- 2022-06-16  MJV FIX: Fixed Issue#78  Fix case-sensitive object names by using quote_ident() all over the place. Also added restriction to not allow case-sensitive target schemas.
-- 2022-06-16  MJV FIX: Fixed Issue#78  Also, since we deferred row copies until the end, we must also defer foreign key constraints to the end as well. 
-- 2022-06-18  MJV FIX: Fixed Issue#79  Fix copying of rows in tables with user-defined column datatypes using COPY method.
-- 2022-06-29  MJV FIX: Fixed Issue#80  Fix copying of rows reported error due to arrays not being initialized properly.
-- 2022-07-15  MJV FIX: Fixed Issue#81  Fix COPY import format for handling NULLs correctly.
-- 2022-09-16  MJV FIX: Fixed Issue#82  Set search_path to public when creating user-defined columns in tables to handle public datatypes like PostGIS. Also fixed a bug in DDL only mode.
-- 2022-09-19  MJV FIX: Fixed Issue#83  Tables with CONSTRAINT DEFs are duplicated as CREATE INDEX statements. Removed CREATE INDEX statements if already defined as CONSTRAINTS.
-- 2022-09-27  MJV FIX: Fixed Issue#85  v13 postgres needs stricter type casting than v14
-- 2022-09-29  MJV FIX: Fixed Issue#86  v12+ handle generated columns by not trying to insert rows into them
-- 2022-09-29  MJV FIX: Fixed Issue#87  v10 requires double quotes around collation name, 11+ doesnt care
-- 2022-12-02  MJV FIX: Fixed Issue#90  Clone functions before views to avoid cloning error for views that call functions.
-- 2022-12-02  MJV FIX: Fixed Issue#91  Fix ownership of objects.  Currently it is defaulting to the one running this script. Let it be the same owner as the source schema to preserve access control.
-- 2022-12-02  MJV FIX: Fixed Issue#92  Default privileges error: Must set the role before executing the command.
-- 2022-12-03  MJV FIX: Fixed Issue#94  Make parameters variadic
-- 2022-12-04  MJV FIX: Fixed Issue#96  PG15 may not populate the collcollate and collctype columns of the pg_collation table.  Handle this.
-- 2022-12-04  MJV FIX: Fixed Issue#97  Regression testing: invalid CASE STATEMENT syntax found.  PG13 is stricter than PG14 and up.  Remove CASE from END CASE to terminate CASE statements.
-- 2022-12-05  MJV FIX: Fixed Issue#95  Implemented owner/ACL rules.
-- 2022-12-06  MJV FIX: Fixed Issue#98  Materialized Views are not populated because they are created before the regular tables are populated. Defer until after tables are populated.
-- 2022-12-07  MJV FIX: Fixed Issue#99  Tables and indexes should mimic the same tablespace used in the source schema.  Only indexes where doing this. Fixed now so both use the same source tablespace.
-- 2022-12-22  MJV FIX: Fixed Issue#100 Fixed case for user-defined type in public schema not handled: citext. See #82 issue that missed this one.
-- 2022-12-22  MJV FIX: Fixed Issue#101 Enhancement: More debugging info, exceptions print out version.
-- 2023-01-10  MJV FIX: Fixed Issue#102 Add alternative to export/import for UDTs, use "text" as an intermediate cast.
--                                      ex: INSERT INTO clone1.address2 (id2, id3, addr) SELECT id2::text::clone1.udt_myint, id3::text::clone1.udt_myint, addr FROM sample.address;
-- 2023-05-17  MJV FIX: Fixed Issue#103 2 problems: handling multiple partitioned tables and not creating FKEYS on partitioned tables since the FKEY created on the parent already propagated down to the partitions.
--                                      The first problem is fixed by modifying the query to work with the current table only.  The 2nd one??????
-- 2023-07-07  EVK FIX: Merged          Fixed problems with the parameters to FUNCTION clone_schema being (text, text, cloneparms[]) instead of (text, text, boolean, boolean) 
--                                      which resulted in the example grant and the drop not working correctly. Also removed some trailing whitespace. Cheers, Ellert van Koperen.
-- 2023-08-04  MJV FIX: Fixed Issue#105 Use the extension's schema not the table's schema.  Don't assume public schema.
-- 2023-09-07  MJV FIX: Fixed Issue#107 Fixed via pull request#109. Increased output length of sequences and identities from 2 to 5.  Also changed SQL for gettting identities owner.
-- 2023-09-07  MJV FIX: Fixed Issue#108:enclose double-quote roles with special characters for setting "OWNER TO"
-- 2024-01-15	 MJV FIX: Fixed Issue#114: varchar arrays cause problems use pg_col_def func() from pg_get_tabledef to fix the problem
-- 2024-01-21  MJV ENH: Add more debug info when sql excecution errors (lastsql variable)
-- 2024-01-22  MJV FIX: Fixed Issue#113: quote_ident() the policy name, and also do not use "qual" column when policy is an INSERT command since it is always null.
-- 2024-01-23  MJV FIX: Fixed Issue#111: defer triggers til after we populate the tables, just like we did with FKeys (Issue#78). See example with emp table and emp_stamp trigger that updates inserted row.
-- 2024-01-24  MJV FIX: Fixed Issue#116: defer creation of materialized view indexes until after we create the deferred materialized views via issue#98.
-- 2024-01-28  MJV FIX: Fixed Issue#117: Fix getting table privs SQL: string_agg wasn't working and no need to double-quote the grantee, that was only intended for owner DDL (Issue#108)
-- 2024-02-20  MJV FIX: Fixed Issue#121: Fix handling of autogenerated columns besides IDENTITY ones.  This required major rewrite to how we get table definition.
--                                       We get it from another gihub project owned by the primary coder of this project, Michael Vitale (https://github.com/MichaelDBA/pg_get_tabledef).
-- 2024-02-22  MJV FIX: Fixed Issue#120: Set sequence owner to column to tie it to the table with the sequence.
-- 2024-02-22  MJV FIX: Fixed Issue#122: Do not create explicit sequence when it is implied via serial definition.

do $$ 
<<first_block>>
DECLARE
    cnt int;
BEGIN
  DROP TYPE IF EXISTS public.cloneparms CASCADE;
  CREATE TYPE public.cloneparms AS ENUM ('DATA', 'NODATA','DDLONLY','NOOWNER','NOACL','VERBOSE','DEBUG','FILECOPY');
  -- END IF;
end first_block $$;


-- select * from public.get_insert_stmt_ddl('clone1','sample','address');
CREATE OR REPLACE FUNCTION public.get_insert_stmt_ddl(
  source_schema text,
  target_schema text,
  atable text,
  bTextCast boolean default False
)
RETURNS text
LANGUAGE plpgsql VOLATILE
AS
$$
  DECLARE
    -- the ddl we're building
    v_insert_ddl text := '';
    v_cols       text := '';
    v_cols_sel   text := '';
    v_cnt        int  := 0;
    v_colrec     record;
    v_schema     text;
  BEGIN
    FOR v_colrec IN
      SELECT c.column_name, c.data_type, c.udt_name, c.udt_schema, c.character_maximum_length, c.is_nullable, c.column_default, c.numeric_precision, c.numeric_scale, c.is_identity, c.identity_generation, c.is_generated 
      FROM information_schema.columns c WHERE (table_schema, table_name) = (source_schema, atable) ORDER BY ordinal_position
    LOOP
      IF v_colrec.udt_schema = 'public' THEN
        v_schema = 'public';
      ELSE
        v_schema = target_schema;
      END IF;
      
      v_cnt = v_cnt + 1;
      IF v_colrec.is_identity = 'YES' OR v_colrec.is_generated = 'ALWAYS' THEN
        -- skip
        continue;
      END IF;

      IF v_colrec.data_type = 'USER-DEFINED' THEN
        IF v_cols = '' THEN
          v_cols     = v_colrec.column_name;
          IF bTextCast THEN 
            -- v_cols_sel = v_colrec.column_name || '::text::' || v_schema || '.' || v_colrec.udt_name;
            IF v_schema = 'public' THEN
              v_cols_sel = v_colrec.column_name || '::' || v_schema || '.' || v_colrec.udt_name;
            ELSE
              v_cols_sel = v_colrec.column_name || '::text::' || v_colrec.udt_name;
            END IF;
          ELSE
            v_cols_sel = v_colrec.column_name || '::' || v_schema || '.' || v_colrec.udt_name;
          END IF;
        ELSE 
          v_cols     = v_cols     || ', ' || v_colrec.column_name;
          IF bTextCast THEN 
            -- v_cols_sel = v_cols_sel || ', ' || v_colrec.column_name || '::text::' || v_schema || '.' || v_colrec.udt_name;
            IF v_schema = 'public' THEN
              v_cols_sel = v_cols_sel || ', ' || v_colrec.column_name || '::' || v_schema || '.' || v_colrec.udt_name;
            ELSE
              v_cols_sel = v_cols_sel || ', ' || v_colrec.column_name || '::text::' || v_colrec.udt_name;
            END IF;
          ELSE
            v_cols_sel = v_cols_sel || ', ' || v_colrec.column_name || '::' || v_schema || '.' || v_colrec.udt_name;
          END IF;
        END IF;
      ELSE
        IF v_cols = '' THEN
          v_cols     = v_colrec.column_name;
          v_cols_sel = v_colrec.column_name;
        ELSE 
          v_cols     = v_cols     || ', ' || v_colrec.column_name;
          v_cols_sel = v_cols_sel || ', ' || v_colrec.column_name;
        END IF;
      END IF;
    END LOOP;

    -- put it all together and return the insert statement
    -- INSERT INTO clone1.address2 (id2, id3, addr) SELECT id2::text::clone1.udt_myint, id3::text::clone1.udt_myint, addr FROM sample.address;    
    v_insert_ddl = 'INSERT INTO ' || target_schema || '.' || atable || ' (' || v_cols || ') ' || 'SELECT ' || v_cols_sel || ' FROM ' || source_schema || '.' || atable || ';';
    RETURN v_insert_ddl;
  END;
$$;

-- Issue#121: removed deprecated function, public.get_table_ddl()
-- Issue#121: removed deprecated function, public.get_table_ddl_complex()
-- Issue#121: add external project function, pg_get_tabledef() as a replacement.

/****************************************************/
/*  Drop In function pg_get_tabledef starts here... */
/****************************************************/
/* ********************************************************************************
COPYRIGHT NOTICE FOLLOWS.  DO NOT REMOVE
Copyright (c) 2021-2024 SQLEXEC LLC

Permission to use, copy, modify, and distribute this software and its documentation 
for any purpose, without fee, and without a written agreement is hereby granted, 
provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

IN NO EVENT SHALL SQLEXEC LLC BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,INDIRECT SPECIAL, 
INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE 
OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF SQLEXEC LLC HAS BEEN ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.

SQLEXEC LLC SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND SQLEXEC LLC HAS 
NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

************************************************************************************ */

-- History:
-- Date	     Description
-- ==========   ======================================================================  
-- 2021-03-20   Original coding using some snippets from 
--              https://stackoverflow.com/questions/2593803/how-to-generate-the-create-table-sql-statement-for-an-existing-table-in-postgr
-- 2021-03-21   Added partitioned table support, i.e., PARTITION BY clause.
-- 2021-03-21   Added WITH clause logic where storage parameters for tables are set.
-- 2021-03-22   Added tablespace logic for tables and indexes.
-- 2021-03-24   Added inheritance-based partitioning support for PG 9.6 and lower.
-- 2022-09-12   Fixed Issue#1: Added fix for PostGIS columns where we do not presume the schema, leave without schema to imply public schema
-- 2022-09-19   Fixed Issue#2: Do not add CREATE INDEX statements if the indexes are defined within the Table definition as ADD CONSTRAINT.
-- 2022-12-03   Fixed: Handle NULL condition for ENUMs
-- 2022-12-07   Fixed: not setting tablespace correctly for user defined tablespaces
-- 2023-04-12   Fixed Issue#6: Handle array types: int, bigint, varchar, even varchars with precisions.
-- 2023-04-13   Fixed Issue#7: Incomplete fixing of issue#6
-- 2023-04-21   Fixed Issue#8: previously returns actual sequence info (aka \d) instead of serial/bigserial def.
-- 2023-04-21   Fixed Issue#10: Consolidated comments into one place under function prototype heading.
-- 2023-05-17   Fixed Issue#13: do not specify FKEY for partitions. It is done on the parent and implied on the partitions, else you get "fkey already exists" error
-- 2023-05-20   Fixed syntax error, missing THEN keyword
-- 2023-05-20   Fixed Issue#11: Handle parent of table being in another schema
-- 2023-07-24   Fixed Issue#14: If multiple triggers are defined on a table, show them all not just the first one.
-- 2023-08-03   Fixed Issue#15: use utd_schema with USER-DEFINED data types, not defaulting to table schema.
-- 2023-08-03   Fixed Issue#16: Make it optional to define the PKEY as external instead of internal.
-- 2023-08-24   Fixed Issue#17: Handle case-sensitive tables.
-- 2023-08-26   Fixed Issue#17: Had to remove quote_ident when identifying case sensitive tables
-- 2023-08-28   Fixed Issue#19: Identified in pull request#18: double-quote reserved keywords
-- 2024-01-25   Fixed Issue#20: Handle output for specifying PKEY_EXTERNAL and FKEYS_EXTERNAL options, which misses all other non-primary constraints.
-- 2024-02-18   Fixed Issue#22: Handle FKEYS_NONE input option, which was previously ignored.
-- 2024-02-19   Fixed Issue#23: Handle complex autogenerated columns. Also append NOT NULL to IDENTITY columns even though technically not necessary.


DROP TYPE IF EXISTS public.tabledefs CASCADE;
CREATE TYPE public.tabledefs AS ENUM ('PKEY_INTERNAL','PKEY_EXTERNAL','FKEYS_INTERNAL', 'FKEYS_EXTERNAL', 'COMMENTS', 'FKEYS_NONE', 'INCLUDE_TRIGGERS', 'NO_TRIGGERS');

-- DROP FUNCTION public.pg_get_coldef(text,text,text,boolean);
CREATE OR REPLACE FUNCTION public.pg_get_coldef(
  in_schema text,
  in_table text,
  in_column text,
  oldway boolean default False
)
RETURNS text
LANGUAGE plpgsql VOLATILE
AS
$$
DECLARE
coldef text;
BEGIN
  IF oldway THEN 
    SELECT pg_catalog.format_type(a.atttypid, a.atttypmod) INTO coldef FROM pg_namespace n, pg_class c, pg_attribute a, pg_type t 
    WHERE n.nspname = in_schema AND n.oid = c.relnamespace AND c.relname = in_table AND a.attname = in_column and a.attnum > 0 AND a.attrelid = c.oid AND a.atttypid = t.oid ORDER BY a.attnum;
    -- RAISE INFO 'DEBUG: oldway=%',coldef;
  ELSE
    -- a.attrelid::regclass::text, a.attname
    SELECT CASE WHEN a.atttypid = ANY ('{int,int8,int2}'::regtype[]) AND EXISTS (SELECT FROM pg_attrdef ad WHERE ad.adrelid = a.attrelid AND ad.adnum   = a.attnum AND 
	  pg_get_expr(ad.adbin, ad.adrelid) = 'nextval(''' || (pg_get_serial_sequence (a.attrelid::regclass::text, a.attname))::regclass || '''::regclass)') THEN CASE a.atttypid 
	  WHEN 'int'::regtype  THEN 'serial' WHEN 'int8'::regtype THEN 'bigserial' WHEN 'int2'::regtype THEN 'smallserial' END ELSE format_type(a.atttypid, a.atttypmod) END AS data_type  
	  INTO coldef FROM pg_namespace n, pg_class c, pg_attribute a, pg_type t 
	  WHERE n.nspname = in_schema AND n.oid = c.relnamespace AND c.relname = in_table AND a.attname = in_column and a.attnum > 0 AND a.attrelid = c.oid AND a.atttypid = t.oid ORDER BY a.attnum;
	  -- RAISE INFO 'DEBUG: oldway=%',coldef;
  END IF;
  RETURN coldef;
END;
$$;

-- SELECT * FROM public.pg_get_tabledef('sample', 'address', false);
DROP FUNCTION IF EXISTS public.pg_get_tabledef(character varying,character varying,boolean,tabledefs[]);
CREATE OR REPLACE FUNCTION public.pg_get_tabledef(
  in_schema varchar,
  in_table varchar,
  _verbose boolean,
  VARIADIC arr public.tabledefs[] DEFAULT '{}':: public.tabledefs[]
)
RETURNS text
LANGUAGE plpgsql VOLATILE
AS
$$
  DECLARE
    v_qualified text := '';
    v_table_ddl text;
    v_table_oid int;
    v_colrec record;
    v_constraintrec record;
    v_trigrec       record;
    v_indexrec record;
    v_rec           record;
    v_constraint_name text;
    v_constraint_def  text;
    v_pkey_def        text := '';
    v_fkey_def        text := '';
    v_fkey_defs       text := '';
    v_trigger text := '';
    v_partition_key text := '';
    v_partbound text;
    v_parent text;
    v_parent_schema text;
    v_persist text;
    v_temp  text := ''; 
    v_relopts text;
    v_tablespace text;
    v_pgversion int;
    bSerial boolean;
    bPartition boolean;
    bInheritance boolean;
    bRelispartition boolean;
    constraintarr text[] := '{}';
    constraintelement text;
    bSkip boolean;
	  bVerbose boolean := False;
	  v_cnt1   integer;
	  v_cnt2   integer;
	  v_src_path_old text := '';
	  v_src_path_new text := '';

    -- assume defaults for ENUMs at the getgo	
  	pkcnt            int := 0;
  	fkcnt            int := 0;
	  trigcnt          int := 0;
	  cmtcnt           int := 0;
    pktype           public.tabledefs := 'PKEY_INTERNAL';
    fktype           public.tabledefs := 'FKEYS_INTERNAL';
    trigtype         public.tabledefs := 'NO_TRIGGERS';
    arglen           integer;
  	vargs            text;
	  avarg            public.tabledefs;

    -- exception variables
    v_ret            text;
    v_diag1          text;
    v_diag2          text;
    v_diag3          text;
    v_diag4          text;
    v_diag5          text;
    v_diag6          text;
	
  BEGIN
    SET client_min_messages = 'notice';
    IF _verbose THEN bVerbose = True; END IF;
    
    -- v17 fix: handle case-sensitive  
    -- v_qualified = in_schema || '.' || in_table;
	
    arglen := array_length($4, 1);
    IF arglen IS NULL THEN
        -- nothing to do, so assume defaults
        NULL;
    ELSE
        -- loop thru args
        -- IF 'NO_TRIGGERS' = ANY ($4)
        -- select array_to_string($4, ',', '***') INTO vargs;
        IF bVerbose THEN RAISE NOTICE 'arguments=%', $4; END IF;
        FOREACH avarg IN ARRAY $4 LOOP
            IF bVerbose THEN RAISE INFO 'arg=%', avarg; END IF;
            IF avarg = 'FKEYS_INTERNAL' OR avarg = 'FKEYS_EXTERNAL' OR avarg = 'FKEYS_NONE' THEN
                fkcnt = fkcnt + 1;
                fktype = avarg;
            ELSEIF avarg = 'INCLUDE_TRIGGERS' OR avarg = 'NO_TRIGGERS' THEN
                trigcnt = trigcnt + 1;
                trigtype = avarg;
            ELSEIF avarg = 'PKEY_EXTERNAL' THEN
                pkcnt = pkcnt + 1;
                pktype = avarg;				                
            ELSEIF avarg = 'COMMENTS' THEN
                cmtcnt = cmtcnt + 1;
                
            END IF;
        END LOOP;
        IF fkcnt > 1 THEN 
  	        RAISE WARNING 'Only one foreign key option can be provided. You provided %', fkcnt;
	          RETURN '';
        ELSEIF trigcnt > 1 THEN 
            RAISE WARNING 'Only one trigger option can be provided. You provided %', trigcnt;
            RETURN '';
        ELSEIF pkcnt > 1 THEN 
            RAISE WARNING 'Only one pkey option can be provided. You provided %', pkcnt;
            RETURN '';			
        ELSEIF cmtcnt > 1 THEN 
            RAISE WARNING 'Only one comments option can be provided. You provided %', cmtcnt;
            RETURN '';			
            
        END IF;		   		   
    END IF;

    SELECT c.oid, (select setting from pg_settings where name = 'server_version_num') INTO v_table_oid, v_pgversion FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind in ('r','p') AND c.relname = in_table AND n.nspname = in_schema;

   -- set search_path = public before we do anything to force explicit schema qualification but dont forget to set it back before exiting...
    SELECT setting INTO v_src_path_old FROM pg_settings WHERE name = 'search_path';

    SELECT REPLACE(REPLACE(setting, '"$user"', '$user'), '$user', '"$user"') INTO v_src_path_old
    FROM pg_settings
    WHERE name = 'search_path';
    -- RAISE INFO 'DEBUG tableddl: saving old search_path: ***%***', v_src_path_old;
    EXECUTE 'SET search_path = "public"';
    SELECT setting INTO v_src_path_new FROM pg_settings WHERE name = 'search_path';
    -- RAISE INFO 'DEBUG tableddl: using new search path=***%***', v_src_path_new;
    
    -- throw an error if table was not found
    IF (v_table_oid IS NULL) THEN
      RAISE EXCEPTION 'table does not exist';
    END IF;

    -- get user-defined tablespaces if applicable
    SELECT tablespace INTO v_temp FROM pg_tables WHERE schemaname = in_schema and tablename = in_table and tablespace IS NOT NULL;
    IF v_temp IS NULL THEN
      v_tablespace := 'TABLESPACE pg_default';
    ELSE
      v_tablespace := 'TABLESPACE ' || v_temp;
    END IF;
    
    -- also see if there are any SET commands for this table, ie, autovacuum_enabled=off, fillfactor=70
    WITH relopts AS (SELECT unnest(c.reloptions) relopts FROM pg_class c, pg_namespace n WHERE n.nspname = in_schema and n.oid = c.relnamespace and c.relname = in_table) 
    SELECT string_agg(r.relopts, ', ') as relopts INTO v_temp from relopts r;
    IF v_temp IS NULL THEN
      v_relopts := '';
    ELSE
      v_relopts := ' WITH (' || v_temp || ')';
    END IF;
    
    -- -----------------------------------------------------------------------------------
    -- Create table defs for partitions/children using inheritance or declarative methods.
    -- inheritance: pg_class.relkind = 'r'   pg_class.relispartition=false   pg_class.relpartbound is NULL
    -- declarative: pg_class.relkind = 'r'   pg_class.relispartition=true    pg_class.relpartbound is NOT NULL
    -- -----------------------------------------------------------------------------------
    v_partbound := '';
    bPartition := False;
    bInheritance := False;
    IF v_pgversion < 100000 THEN
      -- Issue#11: handle parent schema
      SELECT c2.relname parent, c2.relnamespace::regnamespace INTO v_parent, v_parent_schema from pg_class c1, pg_namespace n, pg_inherits i, pg_class c2
      WHERE n.nspname = in_schema and n.oid = c1.relnamespace and c1.relname = in_table and c1.oid = i.inhrelid and i.inhparent = c2.oid and c1.relkind = 'r';      
      IF (v_parent IS NOT NULL) THEN
        bPartition   := True;
        bInheritance := True;
      END IF;
    ELSE
      -- Issue#11: handle parent schema
      SELECT c2.relname parent, c1.relispartition, pg_get_expr(c1.relpartbound, c1.oid, true), c2.relnamespace::regnamespace INTO v_parent, bRelispartition, v_partbound, v_parent_schema from pg_class c1, pg_namespace n, pg_inherits i, pg_class c2
      WHERE n.nspname = in_schema and n.oid = c1.relnamespace and c1.relname = in_table and c1.oid = i.inhrelid and i.inhparent = c2.oid and c1.relkind = 'r';
      IF (v_parent IS NOT NULL) THEN
        bPartition   := True;
        IF bRelispartition THEN
          bInheritance := False;
        ELSE
          bInheritance := True;
        END IF;
      END IF;
    END IF;
    IF bPartition THEN
      --Issue#17 fix for case-sensitive tables
		  -- SELECT count(*) INTO v_cnt1 FROM information_schema.tables t WHERE EXISTS (SELECT REGEXP_MATCHES(s.table_name, '([A-Z]+)','g') FROM information_schema.tables s 
		  -- WHERE t.table_schema=s.table_schema AND t.table_name=s.table_name AND t.table_schema = quote_ident(in_schema) AND t.table_name = quote_ident(in_table) AND t.table_type = 'BASE TABLE');      
		  SELECT count(*) INTO v_cnt1 FROM information_schema.tables t WHERE EXISTS (SELECT REGEXP_MATCHES(s.table_name, '([A-Z]+)','g') FROM information_schema.tables s 
		  WHERE t.table_schema=s.table_schema AND t.table_name=s.table_name AND t.table_schema = in_schema AND t.table_name = in_table AND t.table_type = 'BASE TABLE');      		  
		  
      --Issue#19 put double-quotes around SQL keyword column names
      -- Issue#121: fix keyword lookup for table name not column name that does not apply here
      -- SELECT COUNT(*) INTO v_cnt2 FROM pg_get_keywords() WHERE word = v_colrec.column_name AND catcode = 'R';
      SELECT COUNT(*) INTO v_cnt2 FROM pg_get_keywords() WHERE word = in_table AND catcode = 'R';
		  
      IF bInheritance THEN
        -- inheritance-based
        IF v_cnt1 > 0 OR v_cnt2 > 0 THEN
          v_table_ddl := 'CREATE TABLE ' || in_schema || '."' || in_table || '"( '|| E'\n';        
        ELSE
          v_table_ddl := 'CREATE TABLE ' || in_schema || '.' || in_table || '( '|| E'\n';                
        END IF;

        -- Jump to constraints section to add the check constraints
      ELSE
        -- declarative-based
        IF v_relopts <> '' THEN
          IF v_cnt1 > 0 OR v_cnt2 > 0 THEN
            v_table_ddl := 'CREATE TABLE ' || in_schema || '."' || in_table || '" PARTITION OF ' || in_schema || '.' || v_parent || ' ' || v_partbound || v_relopts || ' ' || v_tablespace || '; ' || E'\n';
				  ELSE
				    v_table_ddl := 'CREATE TABLE ' || in_schema || '.' || in_table || ' PARTITION OF ' || in_schema || '.' || v_parent || ' ' || v_partbound || v_relopts || ' ' || v_tablespace || '; ' || E'\n';
				  END IF;
        ELSE
          IF v_cnt1 > 0 OR v_cnt2 > 0 THEN
            v_table_ddl := 'CREATE TABLE ' || in_schema || '."' || in_table || '" PARTITION OF ' || in_schema || '.' || v_parent || ' ' || v_partbound || ' ' || v_tablespace || '; ' || E'\n';
				  ELSE
				    v_table_ddl := 'CREATE TABLE ' || in_schema || '.' || in_table || ' PARTITION OF ' || in_schema || '.' || v_parent || ' ' || v_partbound || ' ' || v_tablespace || '; ' || E'\n';
				  END IF;
        END IF;
        -- Jump to constraints and index section to add the check constraints and indexes and perhaps FKeys
      END IF;
    END IF;
	  IF bVerbose THEN RAISE INFO '(1)tabledef so far: %', v_table_ddl; END IF;

    IF NOT bPartition THEN
      -- see if this is unlogged or temporary table
      select c.relpersistence into v_persist from pg_class c, pg_namespace n where n.nspname = in_schema and n.oid = c.relnamespace and c.relname = in_table and c.relkind = 'r';
      IF v_persist = 'u' THEN
        v_temp := 'UNLOGGED';
      ELSIF v_persist = 't' THEN
        v_temp := 'TEMPORARY';
      ELSE
        v_temp := '';
      END IF;
    END IF;
    
    -- start the create definition for regular tables unless we are in progress creating an inheritance-based child table
    IF NOT bPartition THEN
      --Issue#17 fix for case-sensitive tables
      -- SELECT count(*) INTO v_cnt1 FROM information_schema.tables t WHERE EXISTS (SELECT REGEXP_MATCHES(s.table_name, '([A-Z]+)','g') FROM information_schema.tables s 
      -- WHERE t.table_schema=s.table_schema AND t.table_name=s.table_name AND t.table_schema = quote_ident(in_schema) AND t.table_name = quote_ident(in_table) AND t.table_type = 'BASE TABLE');   
      SELECT count(*) INTO v_cnt1 FROM information_schema.tables t WHERE EXISTS (SELECT REGEXP_MATCHES(s.table_name, '([A-Z]+)','g') FROM information_schema.tables s 
      WHERE t.table_schema=s.table_schema AND t.table_name=s.table_name AND t.table_schema = in_schema AND t.table_name = in_table AND t.table_type = 'BASE TABLE');         
      IF v_cnt1 > 0 THEN
        v_table_ddl := 'CREATE ' || v_temp || ' TABLE ' || in_schema || '."' || in_table || '" (' || E'\n';
      ELSE
        v_table_ddl := 'CREATE ' || v_temp || ' TABLE ' || in_schema || '.' || in_table || ' (' || E'\n';
      END IF;
    END IF;
    -- RAISE INFO 'DEBUG2: tabledef so far: %', v_table_ddl;    
    -- define all of the columns in the table unless we are in progress creating an inheritance-based child table
    IF NOT bPartition THEN
      FOR v_colrec IN
        SELECT c.column_name, c.data_type, c.udt_name, c.udt_schema, c.character_maximum_length, c.is_nullable, c.column_default, c.numeric_precision, c.numeric_scale, c.is_identity, c.identity_generation, c.is_generated, c.generation_expression        
        FROM information_schema.columns c WHERE (table_schema, table_name) = (in_schema, in_table) ORDER BY ordinal_position
      LOOP
         IF bVerbose THEN RAISE INFO '(col loop) name=%  type=%  udt_name=%  default=%  is_generated=%  gen_expr=%', v_colrec.column_name, v_colrec.data_type, v_colrec.udt_name, v_colrec.column_default, v_colrec.is_generated, v_colrec.generation_expression; END IF;  
         
         -- v17 fix: handle case-sensitive for pg_get_serial_sequence that requires SQL Identifier handling
         -- SELECT CASE WHEN pg_get_serial_sequence(v_qualified, v_colrec.column_name) IS NOT NULL THEN True ELSE False END into bSerial;
         SELECT CASE WHEN pg_get_serial_sequence(quote_ident(in_schema) || '.' || quote_ident(in_table), v_colrec.column_name) IS NOT NULL THEN True ELSE False END into bSerial;
         IF bVerbose THEN
           -- v17 fix: handle case-sensitive for pg_get_serial_sequence that requires SQL Identifier handling
           -- SELECT pg_get_serial_sequence(v_qualified, v_colrec.column_name) into v_temp;
           SELECT pg_get_serial_sequence(quote_ident(in_schema) || '.' || quote_ident(in_table), v_colrec.column_name) into v_temp;
           IF v_temp IS NULL THEN v_temp = 'NA'; END IF;
           SELECT public.pg_get_coldef(in_schema, in_table,v_colrec.column_name) INTO v_diag1;
           RAISE NOTICE 'DEBUG table: %  Column: %  datatype: %  Serial=%  serialval=%  coldef=%', v_qualified, v_colrec.column_name, v_colrec.data_type, bSerial, v_temp, v_diag1;
           RAISE NOTICE 'DEBUG tabledef: %', v_table_ddl;
         END IF;
         
         --Issue#17 put double-quotes around case-sensitive column names
         SELECT COUNT(*) INTO v_cnt1 FROM information_schema.columns t WHERE EXISTS (SELECT REGEXP_MATCHES(s.column_name, '([A-Z]+)','g') FROM information_schema.columns s 
         WHERE t.table_schema=s.table_schema and t.table_name=s.table_name and t.column_name=s.column_name AND t.table_schema = quote_ident(in_schema) AND column_name = v_colrec.column_name);         

         --Issue#19 put double-quotes around SQL keyword column names         
         SELECT COUNT(*) INTO v_cnt2 FROM pg_get_keywords() WHERE word = v_colrec.column_name AND catcode = 'R';
         
         IF v_cnt1 > 0 OR v_cnt2 > 0 THEN
           v_table_ddl := v_table_ddl || '  "' || v_colrec.column_name || '" ';
         ELSE
           v_table_ddl := v_table_ddl || '  ' || v_colrec.column_name || ' ';
         END IF;

         -- Issue#23: Handle autogenerated columns and rewrite as a simpler IF THEN ELSE branch instead of a much more complex embedded CASE STATEMENT
         IF v_colrec.is_generated = 'ALWAYS' and v_colrec.generation_expression IS NOT NULL THEN
             -- searchable tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, COALESCE(translate(email, '@.-'::citext, ' '::text), ''::text)) ) STORED
             v_temp = v_colrec.data_type || ' GENERATED ALWAYS AS (' || v_colrec.generation_expression || ') STORED ';
         ELSEIF v_colrec.udt_name in ('geometry', 'box2d', 'box2df', 'box3d', 'geography', 'geometry_dump', 'gidx', 'spheroid', 'valid_detail') THEN
		         v_temp = v_colrec.udt_name;
		     ELSEIF v_colrec.data_type = 'USER-DEFINED' THEN
		         v_temp = v_colrec.udt_schema || '.' || v_colrec.udt_name;
		     ELSEIF v_colrec.data_type = 'ARRAY' THEN
   		       -- Issue#6 fix: handle arrays
		         v_temp = public.pg_get_coldef(in_schema, in_table,v_colrec.column_name);
             -- v17 fix: handle case-sensitive for pg_get_serial_sequence that requires SQL Identifier handling
  		       -- WHEN pg_get_serial_sequence(v_qualified, v_colrec.column_name) IS NOT NULL 
		     ELSEIF pg_get_serial_sequence(quote_ident(in_schema) || '.' || quote_ident(in_table), v_colrec.column_name) IS NOT NULL THEN
		         -- Issue#8 fix: handle serial. Note: NOT NULL is implied so no need to declare it explicitly
		         v_temp = public.pg_get_coldef(in_schema, in_table,v_colrec.column_name);
		     ELSE
		         v_temp = v_colrec.data_type;
         END IF;
         -- RAISE NOTICE 'column def1=%', v_temp;

         -- handle IDENTITY columns
		     IF v_colrec.is_identity = 'YES' THEN
		         IF v_colrec.identity_generation = 'ALWAYS' THEN 
		             v_temp = v_temp || ' GENERATED ALWAYS AS IDENTITY NOT NULL';
		         ELSE
		             v_temp = v_temp || ' GENERATED BY DEFAULT AS IDENTITY NOT NULL';
		         END IF;
         ELSEIF v_colrec.character_maximum_length IS NOT NULL THEN 
             v_temp = v_temp || ('(' || v_colrec.character_maximum_length || ')');
         ELSEIF v_colrec.numeric_precision > 0 AND v_colrec.numeric_scale > 0 THEN 
             v_temp = v_temp || '(' || v_colrec.numeric_precision || ',' || v_colrec.numeric_scale || ')';
         END IF;

         -- Handle NULL/NOT NULL
         IF bSerial THEN 
             v_temp = v_temp || ' NOT NULL';
         ELSEIF v_colrec.is_nullable = 'NO' THEN 
             v_temp = v_temp || ' NOT NULL';
         ELSEIF v_colrec.is_nullable = 'YES' THEN
             v_temp = v_temp || ' NULL';
         END IF;

         -- Handle defaults
         IF v_colrec.column_default IS NOT null AND NOT bSerial THEN 
             -- RAISE INFO 'Setting default for column, %', v_colrec.column_name;
             v_temp = v_temp || (' DEFAULT ' || v_colrec.column_default);
         END IF;
         v_temp = v_temp || ',' || E'\n';
         -- RAISE NOTICE 'column def2=%', v_temp;
         v_table_ddl := v_table_ddl || v_temp;
         -- RAISE NOTICE 'tabledef=%', v_table_ddl;

      END LOOP;
    END IF;
    IF bVerbose THEN RAISE INFO '(2)tabledef so far: %', v_table_ddl; END IF;
        
    -- define all the constraints: conparentid does not exist pre PGv11
    IF v_pgversion < 110000 THEN
      FOR v_constraintrec IN
        SELECT con.conname as constraint_name, con.contype as constraint_type,
          CASE
            WHEN con.contype = 'p' THEN 1 -- primary key constraint
            WHEN con.contype = 'u' THEN 2 -- unique constraint
            WHEN con.contype = 'f' THEN 3 -- foreign key constraint
            WHEN con.contype = 'c' THEN 4
            ELSE 5
          END as type_rank,
          pg_get_constraintdef(con.oid) as constraint_definition
        FROM pg_catalog.pg_constraint con JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid JOIN pg_catalog.pg_namespace nsp ON nsp.oid = connamespace
        WHERE nsp.nspname = in_schema AND rel.relname = in_table ORDER BY type_rank
      LOOP
        v_constraint_name := v_constraintrec.constraint_name;
        v_constraint_def  := v_constraintrec.constraint_definition;
        IF v_constraintrec.type_rank = 1 THEN
            IF pkcnt = 0 OR pktype = 'PKEY_INTERNAL' THEN
                -- internal def
                v_constraint_name := v_constraintrec.constraint_name;
                v_constraint_def  := v_constraintrec.constraint_definition;
                v_table_ddl := v_table_ddl || '  ' -- note: two char spacer to start, to indent the column
                  || 'CONSTRAINT' || ' '
                  || v_constraint_name || ' '
                  || v_constraint_def
                  || ',' || E'\n';
            ELSE
              -- Issue#16 handle external PG def
              SELECT 'ALTER TABLE ONLY ' || in_schema || '.' || c.relname || ' ADD CONSTRAINT ' || r.conname || ' ' || pg_catalog.pg_get_constraintdef(r.oid, true) || ';' INTO v_pkey_def 
              FROM pg_catalog.pg_constraint r, pg_class c, pg_namespace n where r.conrelid = c.oid and  r.contype = 'p' and n.oid = r.connamespace and n.nspname = in_schema AND c.relname = in_table and r.conname = v_constraint_name;             
            END IF;
            IF bPartition THEN
              continue;
            END IF;
        ELSIF v_constraintrec.type_rank = 3 THEN
            -- handle foreign key constraints
            --Issue#22 fix: added FKEY_NONE check
            IF fktype = 'FKEYS_NONE' THEN
                -- skip
                continue;
            ELSIF fkcnt = 0 OR fktype = 'FKEYS_INTERNAL' THEN
                -- internal def
                v_table_ddl := v_table_ddl || '  ' -- note: two char spacer to start, to indent the column
                  || 'CONSTRAINT' || ' '
                  || v_constraint_name || ' '
                  || v_constraint_def
                  || ',' || E'\n';                
            ELSE
                -- external def
                SELECT 'ALTER TABLE ONLY ' || n.nspname || '.' || c2.relname || ' ADD CONSTRAINT ' || r.conname || ' ' || pg_catalog.pg_get_constraintdef(r.oid, true) || ';' INTO v_fkey_def 
  			        FROM pg_constraint r, pg_class c1, pg_namespace n, pg_class c2 where r.conrelid = c1.oid and  r.contype = 'f' and n.nspname = in_schema and n.oid = r.connamespace and r.conrelid = c2.oid and c2.relname = in_table;
                v_fkey_defs = v_fkey_defs || v_fkey_def || E'\n';
            END IF;
        ELSE
            -- handle all other constraints besides PKEY and FKEYS as internal defs by default
            v_table_ddl := v_table_ddl || '  ' -- note: two char spacer to start, to indent the column
              || 'CONSTRAINT' || ' '
              || v_constraint_name || ' '
              || v_constraint_def
              || ',' || E'\n';            
        END IF;
        if bVerbose THEN RAISE INFO 'DEBUG4: constraint name=% constraint_def=%', v_constraint_name,v_constraint_def; END IF;
        constraintarr := constraintarr || v_constraintrec.constraint_name:: text;
  
      END LOOP;
    ELSE
      -- handle PG versions 11 and up
      -- Issue#20: Fix logic for external PKEY and FKEYS
      FOR v_constraintrec IN
        SELECT con.conname as constraint_name, con.contype as constraint_type,
          CASE
            WHEN con.contype = 'p' THEN 1 -- primary key constraint
            WHEN con.contype = 'u' THEN 2 -- unique constraint
            WHEN con.contype = 'f' THEN 3 -- foreign key constraint
            WHEN con.contype = 'c' THEN 4
            ELSE 5
          END as type_rank,
          pg_get_constraintdef(con.oid) as constraint_definition
        FROM pg_catalog.pg_constraint con JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid JOIN pg_catalog.pg_namespace nsp ON nsp.oid = connamespace
        WHERE nsp.nspname = in_schema AND rel.relname = in_table 
              --Issue#13 added this condition:
              AND con.conparentid = 0 
              ORDER BY type_rank
      LOOP
        v_constraint_name := v_constraintrec.constraint_name;
        v_constraint_def  := v_constraintrec.constraint_definition;
        IF v_constraintrec.type_rank = 1 THEN
            IF pkcnt = 0 OR pktype = 'PKEY_INTERNAL' THEN
                -- internal def
                v_constraint_name := v_constraintrec.constraint_name;
                v_constraint_def  := v_constraintrec.constraint_definition;
                v_table_ddl := v_table_ddl || '  ' -- note: two char spacer to start, to indent the column
                  || 'CONSTRAINT' || ' '
                  || v_constraint_name || ' '
                  || v_constraint_def
                  || ',' || E'\n';
            ELSE
              -- Issue#16 handle external PG def
              SELECT 'ALTER TABLE ONLY ' || in_schema || '.' || c.relname || ' ADD CONSTRAINT ' || r.conname || ' ' || pg_catalog.pg_get_constraintdef(r.oid, true) || ';' INTO v_pkey_def 
              FROM pg_catalog.pg_constraint r, pg_class c, pg_namespace n where r.conrelid = c.oid and  r.contype = 'p' and n.oid = r.connamespace and n.nspname = in_schema AND c.relname = in_table;              
            END IF;
            IF bPartition THEN
              continue;
            END IF;
        ELSIF v_constraintrec.type_rank = 3 THEN
            -- handle foreign key constraints
            --Issue#22 fix: added FKEY_NONE check
            IF fktype = 'FKEYS_NONE' THEN
                -- skip
                continue;            
            ELSIF fkcnt = 0 OR fktype = 'FKEYS_INTERNAL' THEN
                -- internal def
                v_table_ddl := v_table_ddl || '  ' -- note: two char spacer to start, to indent the column
                  || 'CONSTRAINT' || ' '
                  || v_constraint_name || ' '
                  || v_constraint_def
                  || ',' || E'\n';                
            ELSE
                -- external def
                SELECT 'ALTER TABLE ONLY ' || n.nspname || '.' || c2.relname || ' ADD CONSTRAINT ' || r.conname || ' ' || pg_catalog.pg_get_constraintdef(r.oid, true) || ';' INTO v_fkey_def 
  			        FROM pg_constraint r, pg_class c1, pg_namespace n, pg_class c2 where r.conrelid = c1.oid and  r.contype = 'f' and n.nspname = in_schema and n.oid = r.connamespace and r.conrelid = c2.oid and c2.relname = in_table and 
  			        r.conname = v_constraint_name and r.conparentid = 0;
                v_fkey_defs = v_fkey_defs || v_fkey_def || E'\n';
            END IF;
        ELSE
            -- handle all other constraints besides PKEY and FKEYS as internal defs by default
            v_table_ddl := v_table_ddl || '  ' -- note: two char spacer to start, to indent the column
              || 'CONSTRAINT' || ' '
              || v_constraint_name || ' '
              || v_constraint_def
              || ',' || E'\n';            
        END IF;
        if bVerbose THEN RAISE INFO 'DEBUG4: constraint name=% constraint_def=%', v_constraint_name,v_constraint_def; END IF;
        constraintarr := constraintarr || v_constraintrec.constraint_name:: text;
  
       END LOOP;
    END IF;      
    IF bVerbose THEN RAISE INFO '(3)tabledef so far: %', v_table_ddl; END IF;
	
    -- drop the last comma before ending the create statement
    v_table_ddl = substr(v_table_ddl, 0, length(v_table_ddl) - 1) || E'\n';

    -- ---------------------------------------------------------------------------
    -- at this point we have everything up to the last table-enclosing parenthesis
    -- ---------------------------------------------------------------------------
    IF bVerbose THEN RAISE INFO '(4)tabledef so far: %', v_table_ddl; END IF;

    -- See if this is an inheritance-based child table and finish up the table create.
    IF bPartition and bInheritance THEN
      -- Issue#11: handle parent schema
      -- v_table_ddl := v_table_ddl || ') INHERITS (' || in_schema || '.' || v_parent || ') ' || E'\n' || v_relopts || ' ' || v_tablespace || ';' || E'\n';
      IF v_parent_schema = '' OR v_parent_schema IS NULL THEN v_parent_schema = in_schema; END IF;
      v_table_ddl := v_table_ddl || ') INHERITS (' || v_parent_schema || '.' || v_parent || ') ' || E'\n' || v_relopts || ' ' || v_tablespace || ';' || E'\n';
    END IF;

    IF v_pgversion >= 100000 AND NOT bPartition and NOT bInheritance THEN
      -- See if this is a partitioned table (pg_class.relkind = 'p') and add the partitioned key 
      SELECT pg_get_partkeydef(c1.oid) as partition_key INTO v_partition_key FROM pg_class c1 JOIN pg_namespace n ON (n.oid = c1.relnamespace) LEFT JOIN pg_partitioned_table p ON (c1.oid = p.partrelid) 
      WHERE n.nspname = in_schema and n.oid = c1.relnamespace and c1.relname = in_table and c1.relkind = 'p';

      IF v_partition_key IS NOT NULL AND v_partition_key <> '' THEN
        -- add partition clause
        -- NOTE:  cannot specify default tablespace for partitioned relations
        -- v_table_ddl := v_table_ddl || ') PARTITION BY ' || v_partition_key || ' ' || v_tablespace || ';' || E'\n';  
        v_table_ddl := v_table_ddl || ') PARTITION BY ' || v_partition_key || ';' || E'\n';  
      ELSEIF v_relopts <> '' THEN
        v_table_ddl := v_table_ddl || ') ' || v_relopts || ' ' || v_tablespace || ';' || E'\n';  
      ELSE
        -- end the create definition
        v_table_ddl := v_table_ddl || ') ' || v_tablespace || ';' || E'\n';    
      END IF;  
    END IF;

    IF bVerbose THEN RAISE INFO '(5)tabledef so far: %', v_table_ddl; END IF;
    
    -- Add closing paren for regular tables
    -- IF NOT bPartition THEN
    -- v_table_ddl := v_table_ddl || ') ' || v_relopts || ' ' || v_tablespace || E';\n';  
    -- END IF;
    -- RAISE NOTICE 'ddlsofar3: %', v_table_ddl;

    -- Issue#16 create the external PKEY def if indicated
    IF v_pkey_def <> '' THEN
        v_table_ddl := v_table_ddl || v_pkey_def || E'\n';    
    END IF;
   
    -- Issue#20
    IF v_fkey_defs <> '' THEN
	         v_table_ddl := v_table_ddl || v_fkey_defs || E'\n';    
    END IF;
   
    IF bVerbose THEN RAISE INFO '(6)tabledef so far: %', v_table_ddl; END IF;
   
    -- create indexes
    FOR v_indexrec IN
      SELECT indexdef, COALESCE(tablespace, 'pg_default') as tablespace, indexname FROM pg_indexes WHERE (schemaname, tablename) = (in_schema, in_table)
    LOOP
      -- RAISE INFO 'DEBUG6: indexname=%', v_indexrec.indexname;             
      -- loop through constraints and skip ones already defined
      bSkip = False;
      FOREACH constraintelement IN ARRAY constraintarr
      LOOP 
         IF constraintelement = v_indexrec.indexname THEN
             -- RAISE INFO 'DEBUG7: skipping index, %', v_indexrec.indexname;
             bSkip = True;
             EXIT;
         END IF;
      END LOOP;   
      if bSkip THEN CONTINUE; END IF;
      
      -- Add IF NOT EXISTS clause so partition index additions will not be created if declarative partition in effect and index already created on parent
      v_indexrec.indexdef := REPLACE(v_indexrec.indexdef, 'CREATE INDEX', 'CREATE INDEX IF NOT EXISTS');
      -- RAISE INFO 'DEBUG8: adding index, %', v_indexrec.indexname;
      
      -- NOTE:  cannot specify default tablespace for partitioned relations
      IF v_partition_key IS NOT NULL AND v_partition_key <> '' THEN
          v_table_ddl := v_table_ddl || v_indexrec.indexdef || ';' || E'\n';
      ELSE
          v_table_ddl := v_table_ddl || v_indexrec.indexdef || ' TABLESPACE ' || v_indexrec.tablespace || ';' || E'\n';
      END IF;
      
    END LOOP;
    IF bVerbose THEN RAISE INFO '(7)tabledef so far: %', v_table_ddl; END IF;

    -- Issue#20: added logic for table and column comments
    IF  cmtcnt > 0 THEN 
        FOR v_rec IN
          SELECT c.relname, 'COMMENT ON ' || CASE WHEN c.relkind in ('r','p') AND a.attname IS NULL THEN 'TABLE ' WHEN c.relkind in ('r','p') AND a.attname IS NOT NULL THEN 'COLUMN ' WHEN c.relkind = 'f' THEN 'FOREIGN TABLE ' 
                 WHEN c.relkind = 'm' THEN 'MATERIALIZED VIEW ' WHEN c.relkind = 'v' THEN 'VIEW ' WHEN c.relkind = 'i' THEN 'INDEX ' WHEN c.relkind = 'S' THEN 'SEQUENCE ' ELSE 'XX' END || n.nspname || '.' || 
                 CASE WHEN c.relkind in ('r','p') AND a.attname IS NOT NULL THEN quote_ident(c.relname) || '.' || a.attname ELSE quote_ident(c.relname) END || ' IS '   || quote_literal(d.description) || ';' as ddl
	   	    FROM pg_class c JOIN pg_namespace n ON (n.oid = c.relnamespace) LEFT JOIN pg_description d ON (c.oid = d.objoid) LEFT JOIN pg_attribute a ON (c.oid = a.attrelid AND a.attnum > 0 and a.attnum = d.objsubid)
	   	    WHERE d.description IS NOT NULL AND n.nspname = in_schema AND c.relname = in_table ORDER BY 2 desc, ddl
        LOOP
            --RAISE INFO 'comments:%', v_rec.ddl;
            v_table_ddl = v_table_ddl || v_rec.ddl || E'\n';
        END LOOP;   
    END IF;
    IF bVerbose THEN RAISE INFO '(8)tabledef so far: %', v_table_ddl; END IF;
	
    IF trigtype = 'INCLUDE_TRIGGERS' THEN
	    -- Issue#14: handle multiple triggers for a table
      FOR v_trigrec IN
          select pg_get_triggerdef(t.oid, True) || ';' as triggerdef FROM pg_trigger t, pg_class c, pg_namespace n 
          WHERE n.nspname = in_schema and n.oid = c.relnamespace and c.relname = in_table and c.relkind = 'r' and t.tgrelid = c.oid and NOT t.tgisinternal
      LOOP
          v_table_ddl := v_table_ddl || v_trigrec.triggerdef;
          v_table_ddl := v_table_ddl || E'\n';          
          IF bVerbose THEN RAISE INFO 'triggerdef = %', v_trigrec.triggerdef; END IF;
      END LOOP;       	    
    END IF;
  
    IF bVerbose THEN RAISE INFO '(9)tabledef so far: %', v_table_ddl; END IF;
    -- add empty line
    v_table_ddl := v_table_ddl || E'\n';
    IF bVerbose THEN RAISE INFO '(10)tabledef so far: %', v_table_ddl; END IF;
    
    -- reset search_path back to what it was
    IF v_src_path_old = '' THEN
      SELECT set_config('search_path', '', false) into v_temp;
    ELSE
      EXECUTE 'SET search_path = ' || v_src_path_old;
    END IF;

    RETURN v_table_ddl;
	
    EXCEPTION
    WHEN others THEN
    BEGIN
      GET STACKED DIAGNOSTICS v_diag1 = MESSAGE_TEXT, v_diag2 = PG_EXCEPTION_DETAIL, v_diag3 = PG_EXCEPTION_HINT, v_diag4 = RETURNED_SQLSTATE, v_diag5 = PG_CONTEXT, v_diag6 = PG_EXCEPTION_CONTEXT;
      -- v_ret := 'line=' || v_diag6 || '. '|| v_diag4 || '. ' || v_diag1 || ' .' || v_diag2 || ' .' || v_diag3;
      v_ret := 'line=' || v_diag6 || '. '|| v_diag4 || '. ' || v_diag1;
      RAISE EXCEPTION '%', v_ret;
      -- put additional coding here if necessarY
       RETURN '';
    END;

  END;
$$;

/****************************************************/
/*  Drop In function pg_get_tabledef ends here...   */
/****************************************************/


-- Function: clone_schema(text, text, boolean, boolean, boolean)
-- DROP FUNCTION clone_schema(text, text, boolean, boolean, boolean);
-- DROP FUNCTION IF EXISTS public.clone_schema(text, text, boolean, boolean);

DROP FUNCTION IF EXISTS public.clone_schema(text, text, cloneparms[]);
CREATE OR REPLACE FUNCTION public.clone_schema(
    source_schema text,
    dest_schema text,
    VARIADIC arr public.cloneparms[] DEFAULT '{}':: public.cloneparms[])
  RETURNS void AS
$BODY$

--  This function will clone all sequences, tables, data, views & functions from any existing schema to a new one
-- SAMPLE CALL:
-- SELECT clone_schema('sample', 'sample_clone2');

DECLARE
  src_oid          oid;
  tbl_oid          oid;
  func_oid         oid;
  object           text;
  buffer           text;
  buffer2          text;
  buffer3          text;
  srctbl           text;
  aname            text;
  default_         text;
  column_          text;
  qry              text;
  ix_old_name      text;
  ix_new_name      text;
  relpersist       text;
  udt_name         text;
  udt_schema       text;
  bRelispart       bool;
  bChild           bool;
  relknd           text;
  data_type        text;
  ocomment         text;
  adef             text;
  dest_qry         text;
  v_def            text;
  part_range       text;
  src_path_old     text;
  src_path_new     text;
  aclstr           text;
  -- issue#80 initialize arrays properly
  tblarray         text[] := '{}';
  tblarray2        text[] := '{}';
  tblarray3        text[] := '{}';
  tblarray4        text[] := '{}';
  tblelement       text;
  grantor          text;
  grantee          text;
  privs            text;
  seqval           bigint;
  sq_last_value    bigint;
  sq_max_value     bigint;
  sq_start_value   bigint;
  sq_increment_by  bigint;
  sq_min_value     bigint;
  sq_cache_value   bigint;
  sq_is_called     boolean := True;
  sq_is_cycled     boolean;
  is_prokind       boolean;
  abool            boolean;
  sq_data_type     text;
  sq_cycled        char(10);
  sq_owned         text;
  sq_version        text;
  sq_server_version text;
  sq_server_version_num integer;
  bWindows         boolean;
  arec             RECORD;
  cnt              integer;
  cnt1             integer;
  cnt2             integer;
  cnt3             integer;
  cnt4             integer;
  pos              integer;
  tblscopied       integer := 0;
  l_child          integer;
  action           text := 'N/A';
  tblname          text;
  v_ret            text;
  v_diag1          text;
  v_diag2          text;
  v_diag3          text;
  v_diag4          text;
  v_diag5          text;
  v_diag6          text;
  v_dummy          text;
  v_coldef         text;
  v_seqowner       text;
  spath            text;
  spath_tmp        text;
  -- issue#86 fix
  isGenerated      text;
  
  -- issue#91 fix
  tblowner         text;
  func_owner       text;
  func_name        text;
  func_args        text;
  func_argno       integer;
  view_owner       text; 

  -- issue#92    
  calleruser       text;
  
  -- issue#94
  bData            boolean := False;
  bDDLOnly         boolean := False;
  bVerbose         boolean := False;
  bDebug           boolean := False;
  bNoACL           boolean := False;
  bNoOwner         boolean := False;
  arglen           integer;
  vargs            text;
  avarg            public.cloneparms;

  -- issue#98
  mvarray          text[] := '{}';  
  mvscopied        integer := 0;
  
  -- issue#99 tablespaces
  tblspace         text;
  
  -- issue#101
  bFileCopy        boolean := False;
  
  t                timestamptz := clock_timestamp();
  r                timestamptz;
  s                timestamptz;
  lastsql          text := '';
  lasttbl          text := '';
  v_version        text := '2.0 February 20, 2024';

BEGIN
  -- Make sure NOTICE are shown
  SET client_min_messages = 'notice';
  RAISE NOTICE 'clone_schema version %', v_version;

  IF 'DEBUG'   = ANY ($3) THEN bDebug = True; END IF;
  IF 'VERBOSE' = ANY ($3) THEN bVerbose = True; END IF;
  
  -- IF bVerbose THEN RAISE NOTICE 'START: %',clock_timestamp() - t; END IF;
  
  arglen := array_length($3, 1);
  IF arglen IS NULL THEN
    -- nothing to do, so defaults are assumed
    NULL;
  ELSE
    -- loop thru args
    -- IF 'NO_TRIGGERS' = ANY ($3)
    -- select array_to_string($3, ',', '***') INTO vargs;
    IF bDebug THEN RAISE NOTICE 'DEBUG: arguments=%', $3; END IF;
    FOREACH avarg IN ARRAY $3 LOOP
      IF bDebug THEN RAISE NOTICE 'DEBUG: arg=%', avarg; END IF;
      IF avarg = 'DATA' THEN
        bData = True;
      ELSEIF avarg = 'NODATA' THEN
        -- already set to that by default
        bData = False;
      ELSEIF avarg = 'DDLONLY' THEN
        bDDLOnly = True;
      ELSEIF avarg = 'NOACL' THEN
        bNoACL = True;
      ELSEIF avarg = 'NOOWNER' THEN
        bNoOwner = True;        
      -- issue#101 fix
      ELSEIF avarg = 'FILECOPY' THEN
        bFileCopy = True;
      END IF;
    END LOOP;
    IF bData and bDDLOnly THEN 
      RAISE WARNING 'You can only specify DDLONLY or DATA, but not both.';
      RETURN;
    END IF;
  END IF;  
  
  -- Get server version info to handle certain things differently based on the version.
  SELECT setting INTO sq_server_version
  FROM pg_settings
  WHERE name = 'server_version';
  SELECT version() INTO sq_version;
  
  IF POSITION('compiled by Visual C++' IN sq_version) > 0 THEN
      bWindows = True;
      RAISE NOTICE 'Windows: %', sq_version;
  ELSE
      bWindows = False;
      RAISE NOTICE 'Linux: %', sq_version;
  END IF;
  SELECT setting INTO sq_server_version_num
  FROM pg_settings
  WHERE name = 'server_version_num';

  IF sq_server_version_num < 100000 THEN
    IF sq_server_version_num > 90600 THEN
        RAISE WARNING 'Server Version:%  Number:%  PG Versions older than v10 are not supported.  Will try however for PG 9.6...', sq_server_version, sq_server_version_num;
    ELSE
        RAISE WARNING 'Server Version:%  Number:%  PG Versions older than v10 are not supported.  You need to be at minimum version 9.6 to at least try', sq_server_version, sq_server_version_num;
        RETURN;
    END IF;
  END IF;

  -- Check that source_schema exists
  SELECT oid INTO src_oid
  FROM pg_namespace
  WHERE nspname = quote_ident(source_schema);

  IF NOT FOUND
    THEN
    RAISE NOTICE ' source schema % does not exist!', source_schema;
    RETURN ;
  END IF;

  -- Check for case-sensitive target schemas and reject them for now.
  SELECT lower(dest_schema) = dest_schema INTO abool;
  IF not abool THEN
      RAISE NOTICE 'Case-sensitive target schemas are not supported at this time.';
      RETURN;
  END IF;

  -- Check that dest_schema does not yet exist
  PERFORM nspname
  FROM pg_namespace
  WHERE nspname = quote_ident(dest_schema);

  IF FOUND
    THEN
    RAISE NOTICE ' dest schema % already exists!', dest_schema;
    RETURN ;
  END IF;
  IF bDDLOnly and bData THEN
    RAISE WARNING 'You cannot specify to clone data and generate ddl at the same time.';
    RETURN ;
  END IF;

  -- Issue#92
  SELECT current_user into calleruser;
  
  -- Set the search_path to source schema. Before exiting set it back to what it was before.
  -- In order to avoid issues with the special schema name "$user" that may be
  -- returned unquoted by some applications, we ensure it remains double quoted.
  -- MJV FIX: #47
  SELECT setting INTO v_dummy FROM pg_settings WHERE name='search_path';
  IF bDebug THEN RAISE NOTICE 'DEBUG: search_path=%', v_dummy; END IF;
  
  SELECT REPLACE(REPLACE(setting, '"$user"', '$user'), '$user', '"$user"') INTO src_path_old
  FROM pg_settings WHERE name = 'search_path';

  IF bDebug THEN RAISE NOTICE 'DEBUG: src_path_old=%', src_path_old; END IF;

  EXECUTE 'SET search_path = ' || quote_ident(source_schema) ;
  SELECT setting INTO src_path_new FROM pg_settings WHERE name='search_path';
  IF bDebug THEN RAISE NOTICE 'DEBUG: new search_path=%', src_path_new; END IF;

  -- Validate required types exist.  If not, create them.
  SELECT a.objtypecnt, b.permtypecnt INTO cnt, cnt2
  FROM (
      SELECT count(*) AS objtypecnt
      FROM pg_catalog.pg_type t
      LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
  WHERE (t.typrelid = 0
      OR (
          SELECT c.relkind = 'c'
          FROM pg_catalog.pg_class c
          WHERE c.oid = t.typrelid))
      AND NOT EXISTS (
          SELECT 1
          FROM pg_catalog.pg_type el
          WHERE el.oid = t.typelem
              AND el.typarray = t.oid)
          AND n.nspname <> 'pg_catalog'
          AND n.nspname <> 'information_schema'
          AND pg_catalog.pg_type_is_visible(t.oid)
          AND pg_catalog.format_type(t.oid, NULL) = 'obj_type') a, (
          SELECT count(*) AS permtypecnt
          FROM pg_catalog.pg_type t
          LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
      WHERE (t.typrelid = 0
          OR (
              SELECT c.relkind = 'c'
              FROM pg_catalog.pg_class c
              WHERE c.oid = t.typrelid))
          AND NOT EXISTS (
              SELECT 1
              FROM pg_catalog.pg_type el
              WHERE el.oid = t.typelem
                  AND el.typarray = t.oid)
              AND n.nspname <> 'pg_catalog'
              AND n.nspname <> 'information_schema'
              AND pg_catalog.pg_type_is_visible(t.oid)
              AND pg_catalog.format_type(t.oid, NULL) = 'perm_type') b;

  IF cnt = 0 THEN
    CREATE TYPE obj_type AS ENUM ('TABLE','VIEW','COLUMN','SEQUENCE','FUNCTION','SCHEMA','DATABASE');
  END IF;
  IF cnt2 = 0 THEN
    CREATE TYPE perm_type AS ENUM ('SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER','USAGE','CREATE','EXECUTE','CONNECT','TEMPORARY');
  END IF;

  -- Issue#95
  SELECT pg_catalog.pg_get_userbyid(nspowner) INTO buffer FROM pg_namespace WHERE nspname = quote_ident(source_schema);

  IF bDDLOnly THEN
    RAISE NOTICE ' Only generating DDL, not actually creating anything...';
    -- issue#95
    IF bNoOwner THEN
        RAISE INFO 'CREATE SCHEMA %;', quote_ident(dest_schema);    
    ELSE
        RAISE INFO 'CREATE SCHEMA % AUTHORIZATION %;', quote_ident(dest_schema), buffer;    
    END IF;
    RAISE NOTICE 'SET search_path=%;', quote_ident(dest_schema);
  ELSE
    -- issue#95
    IF bNoOwner THEN
        EXECUTE 'CREATE SCHEMA ' || quote_ident(dest_schema) ;
    ELSE
        EXECUTE 'CREATE SCHEMA ' || quote_ident(dest_schema) || ' AUTHORIZATION ' || buffer;
    END IF;
  END IF;

  -- Do system table validations for subsequent system table queries
  -- Issue#65 Fix
  SELECT count(*) into cnt
  FROM pg_attribute
  WHERE  attrelid = 'pg_proc'::regclass AND attname = 'prokind';

  IF cnt = 0 THEN
      is_prokind = False;
  ELSE
      is_prokind = True;
  END IF;

  -- MV: Create Collations
  action := 'Collations';
  cnt := 0;
  -- Issue#96 Handle differently based on PG Versions (PG15 rely on colliculocale, not collcolocate)
  -- perhaps use this logic instead: COALESCE(c.collcollate, c.colliculocale) AS lc_collate, COALESCE(c.collctype, c.colliculocale) AS lc_type  
  IF sq_server_version_num > 150000 THEN 
    FOR arec IN
      SELECT n.nspname AS schemaname, a.rolname AS ownername, c.collname, c.collprovider, c.collcollate AS locale, 
             'CREATE COLLATION ' || quote_ident(dest_schema) || '."' || c.collname || '" (provider = ' || 
             CASE WHEN c.collprovider = 'i' THEN 'icu' WHEN c.collprovider = 'c' THEN 'libc' ELSE '' END || 
             ', locale = ''' || c.colliculocale || ''');' AS COLL_DDL
      FROM pg_collation c
          JOIN pg_namespace n ON (c.collnamespace = n.oid)
          JOIN pg_roles a ON (c.collowner = a.oid)
      WHERE n.nspname = quote_ident(source_schema)
      ORDER BY c.collname
    LOOP
      BEGIN
        cnt := cnt + 1;
        IF bDDLOnly THEN
          RAISE INFO '%', arec.coll_ddl;
        ELSE
          lastsql = arec.coll_ddl;
          EXECUTE arec.coll_ddl;
          lastsql = '';
        END IF;
      END;
    END LOOP;
  ELSIF sq_server_version_num > 100000 THEN   
    FOR arec IN
      SELECT n.nspname AS schemaname, a.rolname AS ownername, c.collname, c.collprovider, c.collcollate AS locale, 
             'CREATE COLLATION ' || quote_ident(dest_schema) || '."' || c.collname || '" (provider = ' || 
             CASE WHEN c.collprovider = 'i' THEN 'icu' WHEN c.collprovider = 'c' THEN 'libc' ELSE '' END || 
             ', locale = ''' || c.collcollate || ''');' AS COLL_DDL
      FROM pg_collation c
          JOIN pg_namespace n ON (c.collnamespace = n.oid)
          JOIN pg_roles a ON (c.collowner = a.oid)
      WHERE n.nspname = quote_ident(source_schema)
      ORDER BY c.collname
    LOOP
      BEGIN
        cnt := cnt + 1;
        IF bDDLOnly THEN
          RAISE INFO '%', arec.coll_ddl;
        ELSE
          lastsql = arec.coll_ddl;
          EXECUTE arec.coll_ddl;
          lastsql = '';
        END IF;
      END;
    END LOOP;
  ELSE
    -- handle 9.6 that is missing some columns in pg_collation
    FOR arec IN
      SELECT n.nspname AS schemaname, a.rolname AS ownername, c.collname, c.collcollate AS locale, 
             'CREATE COLLATION ' || quote_ident(dest_schema) || '."' || c.collname || '" (provider = ' || 
             ', locale = ''' || c.collcollate || ''');' AS COLL_DDL
      FROM pg_collation c
          JOIN pg_namespace n ON (c.collnamespace = n.oid)
          JOIN pg_roles a ON (c.collowner = a.oid)
      WHERE n.nspname = quote_ident(source_schema)
      ORDER BY c.collname
    LOOP
      BEGIN
        cnt := cnt + 1;
        IF bDDLOnly THEN
          RAISE INFO '%', arec.coll_ddl;
        ELSE
          lastsql = arec.coll_ddl;
          EXECUTE arec.coll_ddl;
          lastsql = '';
        END IF;
      END;
    END LOOP;
  END IF;
  RAISE NOTICE '  COLLATIONS cloned: %', LPAD(cnt::text, 5, ' ');

  -- MV: Create Domains
  action := 'Domains';
  cnt := 0;
  FOR arec IN
    SELECT n.nspname AS "Schema", t.typname AS "Name", pg_catalog.format_type(t.typbasetype, t.typtypmod) AS "Type", (
            SELECT c.collname
            FROM pg_catalog.pg_collation c, pg_catalog.pg_type bt
            WHERE c.oid = t.typcollation
                AND bt.oid = t.typbasetype
                AND t.typcollation <> bt.typcollation) AS "Collation", CASE WHEN t.typnotnull THEN
            'not null'
        END AS "Nullable", t.typdefault AS "Default", pg_catalog.array_to_string(ARRAY (
                SELECT pg_catalog.pg_get_constraintdef(r.oid, TRUE)
                FROM pg_catalog.pg_constraint r
                -- Issue#78 FIX: handle case-sensitive names with quote_ident() on t.typename
                WHERE t.oid = r.contypid), ' ') AS "Check", 'CREATE DOMAIN ' || quote_ident(dest_schema) || '.' || quote_ident(t.typname) || ' AS ' || pg_catalog.format_type(t.typbasetype, t.typtypmod) ||
                CASE WHEN t.typnotnull IS NOT NULL THEN
            ' NOT NULL '
        ELSE
            ' '
        END || CASE WHEN t.typdefault IS NOT NULL THEN
            'DEFAULT ' || t.typdefault || ' '
        ELSE
            ' '
        END || pg_catalog.array_to_string(ARRAY (
                SELECT pg_catalog.pg_get_constraintdef(r.oid, TRUE)
                FROM pg_catalog.pg_constraint r
                WHERE t.oid = r.contypid), ' ') || ';' AS DOM_DDL
    FROM pg_catalog.pg_type t
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typtype = 'd'
        AND n.nspname = quote_ident(source_schema)
        AND pg_catalog.pg_type_is_visible(t.oid)
    ORDER BY 1, 2
  LOOP
    BEGIN
      cnt := cnt + 1;
      IF bDDLOnly THEN
        RAISE INFO '%', arec.dom_ddl;
      ELSE
        lastsql = arec.dom_ddl;
        EXECUTE arec.dom_ddl;
        lastsql = '';
      END IF;
    END;
  END LOOP;
  RAISE NOTICE '     DOMAINS cloned: %', LPAD(cnt::text, 5, ' ');

  -- MV: Create types
  action := 'Types';
  cnt := 0;
  lastsql = '';
  FOR arec IN
    -- Fixed Issue#108:enclose double-quote roles with special characters for setting "OWNER TO"
    -- SELECT c.relkind, n.nspname AS schemaname, t.typname AS typname, t.typcategory, pg_catalog.pg_get_userbyid(t.typowner) AS owner, CASE WHEN t.typcategory = 'C' THEN
    SELECT c.relkind, n.nspname AS schemaname, t.typname AS typname, t.typcategory, '"' || pg_catalog.pg_get_userbyid(t.typowner) || '"' AS owner, CASE WHEN t.typcategory = 'C' THEN
            'CREATE TYPE ' || quote_ident(dest_schema) || '.' || t.typname || ' AS (' || array_to_string(array_agg(a.attname || ' ' || pg_catalog.format_type(a.atttypid, a.atttypmod)
                ORDER BY c.relname, a.attnum), ', ') || ');'
        WHEN t.typcategory = 'E' THEN
            'CREATE TYPE ' || quote_ident(dest_schema) || '.' || t.typname || ' AS ENUM (' || REPLACE(quote_literal(array_to_string(array_agg(e.enumlabel ORDER BY e.enumsortorder), ',')), ',', ''',''') || ');'
        ELSE
            ''
        END AS type_ddl
    FROM pg_type t
        JOIN pg_namespace n ON (n.oid = t.typnamespace)
        LEFT JOIN pg_enum e ON (t.oid = e.enumtypid)
        LEFT JOIN pg_class c ON (c.reltype = t.oid)
        LEFT JOIN pg_attribute a ON (a.attrelid = c.oid)
    WHERE n.nspname = quote_ident(source_schema)
        AND (c.relkind IS NULL
            OR c.relkind = 'c')
        AND t.typcategory IN ('C', 'E')
    GROUP BY 1, 2, 3, 4, 5
    ORDER BY n.nspname, t.typcategory, t.typname

  LOOP
    BEGIN
      cnt := cnt + 1;
      -- Keep composite and enum types in separate branches for fine tuning later if needed.
      IF arec.typcategory = 'E' THEN
        IF bDDLOnly THEN
          RAISE INFO '%', arec.type_ddl;
          
          --issue#95
          IF NOT bNoOwner THEN
            -- Fixed Issue#108: double-quote roles in case they have special characters
            RAISE INFO 'ALTER TYPE % OWNER TO  %;', quote_ident(dest_schema) || '.' || arec.typname, arec.owner;
          END IF;
        ELSE
          lastsql = arec.type_ddl;
          EXECUTE arec.type_ddl;
          lastsql = '';

          --issue#95
          IF NOT bNoOwner THEN
              -- Fixed Issue#108: double-quote roles in case they have special characters
	            EXECUTE 'ALTER TYPE ' || quote_ident(dest_schema) || '.' || arec.typname || ' OWNER TO ' || arec.owner;
	        END IF;
        END IF;
      ELSIF arec.typcategory = 'C' THEN
        IF bDDLOnly THEN
          RAISE INFO '%', arec.type_ddl;
          --issue#95
          IF NOT bNoOwner THEN
            -- Fixed Issue#108: double-quote roles in case they have special characters
            RAISE INFO 'ALTER TYPE % OWNER TO  %;', quote_ident(dest_schema) || '.' || arec.typname, arec.owner;
          END IF;
        ELSE
          lastsql = arec.type_ddl;
          EXECUTE arec.type_ddl;
          lastsql = '';
          --issue#95
          IF NOT bNoOwner THEN
              -- Fixed Issue#108: double-quote roles in case they have special characters
	            EXECUTE 'ALTER TYPE ' || quote_ident(dest_schema) || '.' || arec.typname || ' OWNER TO ' || arec.owner;
	        END IF;
        END IF;
      ELSE
          RAISE NOTICE ' Unhandled type:%-%', arec.typcategory, arec.typname;
      END IF;
    END;
  END LOOP;
  RAISE NOTICE '       TYPES cloned: %', LPAD(cnt::text, 5, ' ');

  -- Create sequences
  action := 'Sequences';
  
  cnt := 0;
  -- fix#63  get from pg_sequences not information_schema
  -- fix#63  take 2: get it from information_schema.sequences since we need to treat IDENTITY columns differently.
  -- fix#95  get owner as well by joining to pg_sequences
  -- fix#106 we can get owner info with pg_class, pg_user/pg_group, and information_schema.sequences, so we can avoid the hit to pg_sequences which is not available in 9.6
  FOR object, buffer IN
    -- Fixed Issue#108:
    -- SELECT s1.sequence_name::text, s2.sequenceowner FROM information_schema.sequences s1 JOIN pg_sequences s2 ON (s1.sequence_schema = s2.schemaname AND s1.sequence_name = s2.sequencename) AND s1.sequence_schema = quote_ident(source_schema)
    SELECT s.sequence_name::text, '"' || u.usename || '"' as owner FROM information_schema.sequences s JOIN pg_class c ON (s.sequence_name = c.relname AND s.sequence_schema = c.relnamespace::regnamespace::text) JOIN pg_user u ON (c.relowner = u.usesysid) 
    WHERE c.relkind = 'S' AND s.sequence_schema = quote_ident(source_schema)
    UNION SELECT s.sequence_name::text, g.groname as owner FROM information_schema.sequences s JOIN pg_class c ON (s.sequence_name = c.relname AND s.sequence_schema = c.relnamespace::regnamespace::text) JOIN pg_group g ON (c.relowner = g.grosysid) 
    WHERE c.relkind = 'S' AND s.sequence_schema = quote_ident(source_schema)
  LOOP
    cnt := cnt + 1;
    -- Issue#122: bypass serial columns (smallserial, serial, bigserial), not implemented yet because some explicit sequence defs show up as serial????
    -- SELECT public.pg_get_coldef('sample', 'statuses', 'id', false);
    -- NEED TO GET TABLE NAME!!!!!!!
    -- SELECT public.pg_get_coldef(quote_ident(source_schema), quote_ident(in_table,v_colrec.column_name) INTO v_coldef;

    IF bDDLOnly THEN
      -- issue#95
      RAISE INFO '%', 'CREATE SEQUENCE ' || quote_ident(dest_schema) || '.' || quote_ident(object) || ';';
      IF NOT bNoOwner THEN    
        -- Fixed Issue#108: double-quote roles in case they have special characters
        RAISE INFO '%', 'ALTER  SEQUENCE ' || quote_ident(dest_schema) || '.' || quote_ident(object) || ' OWNER TO ' || buffer || ';';
      END IF;
    ELSE
      buffer2 = 'CREATE SEQUENCE ' || quote_ident(dest_schema) || '.' || quote_ident(object) || ';'; 
      IF bDebug THEN RAISE NOTICE 'DEBUG: %',buffer2; END IF;
      EXECUTE buffer2;

      -- issue#95
      IF NOT bNoOwner THEN    
        -- Fixed Issue#108: double-quote roles in case they have special characters
        EXECUTE 'ALTER SEQUENCE '  || quote_ident(dest_schema) || '.' || quote_ident(object) || ' OWNER TO ' || buffer;
      END IF;
    END IF;
    srctbl := quote_ident(source_schema) || '.' || quote_ident(object);

    -- Issue#120: assign the sequence owner if applicable
    WITH depends AS (SELECT c.oid, n.nspname, c.relname seqname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = object AND n.nspname = quote_ident(source_schema) ORDER BY 2, 3)
    SELECT pg_catalog.quote_ident(n.nspname) || '.' || pg_catalog.quote_ident(c.relname) || '.' || pg_catalog.quote_ident(a.attname) INTO v_seqowner
    FROM pg_catalog.pg_class c INNER JOIN pg_catalog.pg_depend d ON c.oid=d.refobjid INNER JOIN pg_catalog.pg_namespace n ON n.oid=c.relnamespace INNER JOIN pg_catalog.pg_attribute a ON (a.attrelid=c.oid AND a.attnum=d.refobjsubid) 
    INNER JOIN depends d2 ON (d.objid = d2.oid) WHERE d.classid='pg_catalog.pg_class'::pg_catalog.regclass AND d.refclassid='pg_catalog.pg_class'::pg_catalog.regclass AND d.deptype IN ('a', 'i');
		
		IF v_seqowner IS NULL THEN
		    -- nothing to do
		    IF bDebug THEN RAISE NOTICE 'DEBUG: Not generating sequence owner for object=%',object; END IF;
		ELSE
		    v_seqowner := REPLACE(v_seqowner, quote_ident(source_schema), quote_ident(dest_schema));
		    buffer = 'ALTER SEQUENCE ' || quote_ident(dest_schema) || '.' || object || ' OWNED BY ' || v_seqowner || ';';
		    IF bDebug THEN RAISE NOTICE 'DEBUG: object=%  Sequence owner=%  buffer=%',object, v_seqowner, buffer; END IF;
		    -- Need to defer until after tables are created
		    tblarray4 := tblarray4 || buffer;
		    -- EXECUTE buffer;
    END IF;

    IF sq_server_version_num < 100000 THEN
      EXECUTE 'SELECT last_value, is_called FROM ' || quote_ident(source_schema) || '.' || quote_ident(object) || ';' INTO sq_last_value, sq_is_called;
      EXECUTE 'SELECT maximum_value, start_value, increment, minimum_value, 1 cache_size, cycle_option, data_type
               FROM information_schema.sequences WHERE sequence_schema='|| quote_literal(source_schema) || ' AND sequence_name=' || quote_literal(object) || ';'
               INTO sq_max_value, sq_start_value, sq_increment_by, sq_min_value, sq_cache_value, sq_is_cycled, sq_data_type;
      IF sq_is_cycled
        THEN
          sq_cycled := 'CYCLE';
      ELSE
          sq_cycled := 'NO CYCLE';
      END IF;

      qry := 'ALTER SEQUENCE '   || quote_ident(dest_schema) || '.' || quote_ident(object)
             || ' INCREMENT BY ' || sq_increment_by
             || ' MINVALUE '     || sq_min_value
             || ' MAXVALUE '     || sq_max_value
             -- will update current sequence value after this
             || ' START WITH '   || sq_start_value
             || ' RESTART '      || sq_min_value
             || ' CACHE '        || sq_cache_value
             || ' '              || sq_cycled || ' ;' ;
    ELSE
      EXECUTE 'SELECT max_value, start_value, increment_by, min_value, cache_size, cycle, data_type, COALESCE(last_value, 1)
            FROM pg_catalog.pg_sequences WHERE schemaname='|| quote_literal(source_schema) || ' AND sequencename=' || quote_literal(object) || ';'
            INTO sq_max_value, sq_start_value, sq_increment_by, sq_min_value, sq_cache_value, sq_is_cycled, sq_data_type, sq_last_value;
      IF sq_is_cycled
        THEN
          sq_cycled := 'CYCLE';
      ELSE
          sq_cycled := 'NO CYCLE';
      END IF;

      qry := 'ALTER SEQUENCE '   || quote_ident(dest_schema) || '.' || quote_ident(object)
             || ' AS ' || sq_data_type
             || ' INCREMENT BY ' || sq_increment_by
             || ' MINVALUE '     || sq_min_value
             || ' MAXVALUE '     || sq_max_value
             -- will update current sequence value after this
             || ' START WITH '   || sq_start_value
             || ' RESTART '      || sq_min_value
             || ' CACHE '        || sq_cache_value
             || ' '              || sq_cycled || ' ;' ;
    END IF;

    IF bDDLOnly THEN
      RAISE INFO '%', qry;
    ELSE
      lastsql = qry;
      EXECUTE qry;
      lastsql = '';
    END IF;

    buffer := quote_ident(dest_schema) || '.' || quote_ident(object);
    IF bData THEN
      EXECUTE 'SELECT setval( ''' || buffer || ''', ' || sq_last_value || ', ' || sq_is_called || ');' ;
    ELSE
      if bDDLOnly THEN
        -- fix#63
        --  RAISE INFO '%', 'SELECT setval( ''' || buffer || ''', ' || sq_start_value || ', ' || sq_is_called || ');' ;
        RAISE INFO '%', 'SELECT setval( ''' || buffer || ''', ' || sq_last_value || ', ' || sq_is_called || ');' ;
      ELSE
        -- fix#63
        -- EXECUTE 'SELECT setval( ''' || buffer || ''', ' || sq_start_value || ', ' || sq_is_called || ');' ;
        EXECUTE 'SELECT setval( ''' || buffer || ''', ' || sq_last_value || ', ' || sq_is_called || ');' ;
      END IF;

    END IF;
  END LOOP;
  RAISE NOTICE '   SEQUENCES cloned: %', LPAD(cnt::text, 5, ' ');


  -- Create tables including partitioned ones (parent/children) and unlogged ones.  Order by is critical since child partition range logic is dependent on it.
  action := 'Tables';
  SELECT setting INTO v_dummy FROM pg_settings WHERE name='search_path';
  IF bDebug THEN RAISE NOTICE 'DEBUG: search_path=%', v_dummy; END IF;
  
  cnt := 0;
  lasttbl = '';
  -- Issue#61 FIX: use set_config for empty string
  -- SET search_path = '';
  SELECT set_config('search_path', '', false) into v_dummy;
  IF bDebug THEN RAISE NOTICE 'DEBUG: setting search_path to empty string:%', v_dummy; END IF;
  -- Fix#86 add isgenerated to column list
  -- Fix#91 add tblowner for setting the table ownership to that of the source
  -- Fix#99 added join to pg_tablespace
  
  -- Handle PG versions greater than last major/minor version of PG 9.6.24
  IF sq_server_version_num > 90624 THEN
  FOR tblname, relpersist, bRelispart, relknd, data_type, udt_name, udt_schema, ocomment, l_child, isGenerated, tblowner, tblspace  IN
    -- 2021-03-08 MJV #39 fix: change sql to get indicator of user-defined columns to issue warnings
    -- select c.relname, c.relpersistence, c.relispartition, c.relkind
    -- FROM pg_class c, pg_namespace n where n.oid = c.relnamespace and n.nspname = quote_ident(source_schema) and c.relkind in ('r','p') and
    -- order by c.relkind desc, c.relname
    --Fix#65 add another left join to distinguish child tables by inheritance
    -- Fix#86 add is_generated to column select
    -- Fix#91 add tblowner to the select
    -- Fix#105 need a different kinda distinct to avoid retrieving a table twice in the case of a table with multiple USER-DEFINED datatypes using DISTINCT ON instead of just DISTINCT
    --SELECT DISTINCT c.relname, c.relpersistence, c.relispartition, c.relkind, co.data_type, co.udt_name, co.udt_schema, obj_description(c.oid), i.inhrelid, 
    --                COALESCE(co.is_generated, ''), pg_catalog.pg_get_userbyid(c.relowner) as "Owner", CASE WHEN reltablespace = 0 THEN 'pg_default' ELSE ts.spcname END as tablespace
    -- fixed #108 by enclosing owner in double quotes to avoid errors for bad characters like #.@...
    -- SELECT DISTINCT ON (c.relname, c.relpersistence, c.relispartition, c.relkind, co.data_type) c.relname, c.relpersistence, c.relispartition, c.relkind, co.data_type, co.udt_name, co.udt_schema, obj_description(c.oid), i.inhrelid, 
    SELECT DISTINCT ON (c.relname, c.relpersistence, c.relispartition, c.relkind, co.data_type) c.relname, c.relpersistence, c.relispartition, c.relkind, co.data_type, co.udt_name, co.udt_schema, obj_description(c.oid), i.inhrelid, 
                    COALESCE(co.is_generated, ''), '"' || pg_catalog.pg_get_userbyid(c.relowner) || '"' as "Owner", CASE WHEN reltablespace = 0 THEN 'pg_default' ELSE ts.spcname END as tablespace                    
    FROM pg_class c
        JOIN pg_namespace n ON (n.oid = c.relnamespace
                AND n.nspname = quote_ident(source_schema)
                AND c.relkind IN ('r', 'p'))
        LEFT JOIN information_schema.columns co ON (co.table_schema = n.nspname
                AND co.table_name = c.relname
                AND (co.data_type = 'USER-DEFINED' OR co.is_generated = 'ALWAYS'))
        LEFT JOIN pg_inherits i ON (c.oid = i.inhrelid) 
        -- issue#99 added join
        LEFT JOIN pg_tablespace ts ON (c.reltablespace = ts.oid) 
    ORDER BY c.relkind DESC, c.relname
  LOOP
    cnt := cnt + 1;
    lastsql = '';
    
    -- Issue#121 we may have dup tables due to multiple user-defined different datatypes, so skip 2-n occurences of them
    IF lasttbl = tblname THEN
        IF bDebug THEN RAISE INFO 'skipping dup table, %', tblname; END IF;
        continue;
    END IF;
    
    lasttbl = tblname;
    IF l_child IS NULL THEN
      bChild := False;
    ELSE
      bChild := True;
    END IF;
    IF bDebug THEN RAISE NOTICE 'DEBUG: TABLE START --> table=%  bRelispart=%  relkind=%  bChild=%',tblname, bRelispart, relknd, bChild; END IF;

    IF data_type = 'USER-DEFINED' THEN
      IF bDebug THEN RAISE NOTICE 'DEBUG: Table (%) has column(s) with user-defined types so using pg_get_tabledef() instead of CREATE TABLE LIKE construct.',tblname; END IF;
      cnt :=cnt;
    END IF;
    buffer := quote_ident(dest_schema) || '.' || quote_ident(tblname);
    buffer2 := '';
    IF relpersist = 'u' THEN
      buffer2 := 'UNLOGGED ';
    END IF;
    IF relknd = 'r' THEN
      IF bDDLOnly THEN
        IF data_type = 'USER-DEFINED' THEN
          -- FIXED #65, #67
          -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
          -- FIX: #121 Use pg_get_tabledef instead
          SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');          
          buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
          RAISE INFO '%', buffer3;
          -- issue#91 fix
          -- issue#95
          IF NOT bNoOwner THEN    
            -- Fixed Issue#108: double-quote roles in case they have special characters
            RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || tblname, tblowner;
          END IF;
        ELSE
          IF NOT bChild THEN
            RAISE INFO '%', 'CREATE ' || buffer2 || 'TABLE ' || buffer || ' (LIKE ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' INCLUDING ALL);';
            -- issue#91 fix
             -- issue#95
            IF NOT bNoOwner THEN    
              -- Fixed Issue#108: double-quote roles in case they have special characters
              RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || tblname, tblowner;
            END IF;
            
            -- issue#99 
            IF tblspace <> 'pg_default' THEN
              -- replace with user-defined tablespace
              -- ALTER TABLE myschema.mytable SET TABLESPACE usrtblspc;
              RAISE INFO 'ALTER TABLE IF EXISTS % SET TABLESPACE %;', quote_ident(dest_schema) || '.' || tblname, tblspace;
            END IF;
          ELSE
            -- FIXED #65, #67
            -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
            -- FIX: #121 Use pg_get_tabledef instead
            -- SELECT * INTO buffer3 FROM public.get_table_ddl(quote_ident(source_schema), tblname, False);
            SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
            buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
            RAISE INFO '%', buffer3;
            -- issue#91 fix
            -- issue#95
            IF NOT bNoOwner THEN    
              -- Fixed Issue#108: double-quote roles in case they have special characters
              RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || tblname, tblowner;
            END IF;
          END IF;
        END IF;
      ELSE
        IF data_type = 'USER-DEFINED' THEN
          -- FIXED #65, #67
          -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
          -- FIX: #121 Use pg_get_tabledef instead
          -- SELECT * INTO buffer3 FROM public.get_table_ddl(quote_ident(source_schema), tblname, False);
          -- SELECT * INTO buffer3 FROM public.get_table_ddl_complex(source_schema, dest_schema, tblname, sq_server_version_num);     
          SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
          buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
          IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef01a:%', buffer3; END IF;
          -- #82: Table def should be fully qualified with target schema, 
          --      so just make search path = public to handle extension types that should reside in public schema
          v_dummy = 'public';
          SELECT set_config('search_path', v_dummy, false) into v_dummy;
          lastsql = buffer3;
          EXECUTE buffer3;
          lastsql = '';
          -- issue#91 fix
          -- issue#95
          IF NOT bNoOwner THEN    
            -- Fixed Issue#108: double-quote roles in case they have special characters
            buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || tblname || ' OWNER TO ' || tblowner;
            lastsql = buffer3;
            EXECUTE buffer3;
            lastsql = '';
          END IF;
        ELSE
          IF (NOT bChild OR bRelispart) THEN
            buffer3 := 'CREATE ' || buffer2 || 'TABLE ' || buffer || ' (LIKE ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' INCLUDING ALL)';
            IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef02:%', buffer3; END IF;
            lastsql = buffer3;
            EXECUTE buffer3;
            lastsql = '';
            -- issue#91 fix
            -- issue#95
            IF NOT bNoOwner THEN    
              -- Fixed Issue#108: double-quote roles in case they have special characters
              buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.'  || quote_ident(tblname) || ' OWNER TO ' || tblowner;
              lastsql = buffer3;
              EXECUTE buffer3;
              lastsql = '';
            END IF;
            
            -- issue#99
            IF tblspace <> 'pg_default' THEN
              -- replace with user-defined tablespace
              -- ALTER TABLE myschema.mytable SET TABLESPACE usrtblspc;
              buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || tblname || ' SET TABLESPACE ' || tblspace;
              lastsql = buffer3;
              EXECUTE buffer3;
              lastsql = '';
            END IF;

          ELSE
            -- FIXED #65, #67
            -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
            -- FIX: #121 Use pg_get_tabledef instead
            -- SELECT * INTO buffer3 FROM public.get_table_ddl(quote_ident(source_schema), tblname, False);
            SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
            buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
            -- set client_min_messages higher to avoid messages like this:
            -- NOTICE:  merging column "city_id" with inherited definition
            set client_min_messages = 'WARNING';
            IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef03:%', buffer3; END IF;
            lastsql = buffer3;
            EXECUTE buffer3;
            lastsql = '';
            -- issue#91 fix
            -- issue#95
            IF NOT bNoOwner THEN
              -- Fixed Issue#108: double-quote roles in case they have special characters
              buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || tblname || ' OWNER TO ' || tblowner;
              lastsql = buffer3;
              EXECUTE buffer3;
              lastsql = '';
            END IF;

            -- reset it back, only get these for inheritance-based tables
            set client_min_messages = 'notice';
          END IF;
        END IF;
        -- Add table comment.
        IF ocomment IS NOT NULL THEN
          lastsql = 'COMMENT ON TABLE...';
          EXECUTE 'COMMENT ON TABLE ' || buffer || ' IS ' || quote_literal(ocomment);
          lastsql = '';
        END IF;
      END IF;
    ELSIF relknd = 'p' THEN
      -- define parent table and assume child tables have already been created based on top level sort order.
      -- Issue #103 Put the complex query into its own function, get_table_ddl_complex()
      -- FIX: #121 Use pg_get_tabledef instead
      -- SELECT * INTO qry FROM public.get_table_ddl_complex(source_schema, dest_schema, tblname, sq_server_version_num);
      SELECT * INTO qry FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, bDebug, 'FKEYS_NONE');                      
      qry := REPLACE(qry, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
      IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef04 - %', qry; END IF;

      IF bDDLOnly THEN
        RAISE INFO '%', qry;
        -- issue#95
        IF NOT bNoOwner THEN
            -- Fixed Issue#108: double-quote roles in case they have special characters
            RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || quote_ident(tblname), tblowner;
        END IF;
      ELSE
        -- Issue#103: we need to always set search_path priority to target schema when we execute DDL
        IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef04 context: old search path=%  new search path=% current search path=%', src_path_old, src_path_new, v_dummy; END IF;
        SELECT setting INTO spath_tmp FROM pg_settings WHERE name = 'search_path';   
        IF spath_tmp <> dest_schema THEN
          -- change it to target schema and don't forget to change it back after we execute the DDL
          spath = 'SET search_path = "' || dest_schema || '"';
          IF bDebug THEN RAISE NOTICE 'DEBUG: changing search_path --> %', spath; END IF;
          EXECUTE spath;
          SELECT setting INTO v_dummy FROM pg_settings WHERE name = 'search_path';   
          IF bDebug THEN RAISE NOTICE 'DEBUG: search_path changed to %', v_dummy; END IF;
        END IF;
        IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef04:%', qry; END IF;
        lastsql = qry;
        EXECUTE qry;
        lastsql = '';
        
        -- Issue#103
        -- Set search path back to what it was
        spath = 'SET search_path = "' || spath_tmp || '"';
        EXECUTE spath;
        SELECT setting INTO v_dummy FROM pg_settings WHERE name = 'search_path';   
        IF bDebug THEN RAISE NOTICE 'DEBUG: search_path changed back to %', v_dummy; END IF;
        
        -- issue#91 fix
        -- issue#95
        IF NOT bNoOwner THEN
          -- Fixed Issue#108: double-quote roles in case they have special characters
          buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || ' OWNER TO ' || tblowner;
          lastsql = buffer3;
          EXECUTE buffer3;
          lastsql = '';
        END IF;
        
      END IF;
      -- loop for child tables and alter them to attach to parent for specific partition method.
      -- Issue#103 fix: only loop for the table we are currently processing, tblname!
      FOR aname, part_range, object IN
        SELECT quote_ident(dest_schema) || '.' || c1.relname as tablename, pg_catalog.pg_get_expr(c1.relpartbound, c1.oid) as partrange, quote_ident(dest_schema) || '.' || c2.relname as object
        FROM pg_catalog.pg_class c1, pg_namespace n, pg_catalog.pg_inherits i, pg_class c2
        WHERE n.nspname = quote_ident(source_schema) AND c1.relnamespace = n.oid AND c1.relkind = 'r' 
        -- Issue#103: added this condition to only work on current partitioned table.  The problem was regression testing previously only worked on one partition table clone case
        AND c2.relname = tblname AND 
        c1.relispartition AND c1.oid=i.inhrelid AND i.inhparent = c2.oid AND c2.relnamespace = n.oid ORDER BY pg_catalog.pg_get_expr(c1.relpartbound, c1.oid) = 'DEFAULT',
        c1.oid::pg_catalog.regclass::pg_catalog.text
      LOOP
        qry := 'ALTER TABLE ONLY ' || object || ' ATTACH PARTITION ' || aname || ' ' || part_range || ';';
        IF bDebug THEN RAISE NOTICE 'DEBUG: %',qry; END IF;
        -- issue#91, not sure if we need to do this for child tables
        -- issue#95 we dont set ownership here
        IF bDDLOnly THEN
          RAISE INFO '%', qry;
          IF NOT bNoOwner THEN
            NULL;
          END IF;
        ELSE
          lastsql = qry;
          EXECUTE qry;
          lastsql = '';
          IF NOT bNoOwner THEN
            NULL;
          END IF;
        END IF;
      END LOOP;
    END IF;
    
    -- INCLUDING ALL creates new index names, we restore them to the old name.
    -- There should be no conflicts since they live in different schemas
    FOR ix_old_name, ix_new_name IN
      SELECT old.indexname, new.indexname
      FROM pg_indexes old, pg_indexes new
      WHERE old.schemaname = source_schema
        AND new.schemaname = dest_schema
        AND old.tablename = new.tablename
        AND old.tablename = tblname
        AND old.indexname <> new.indexname
        AND regexp_replace(old.indexdef, E'.*USING','') = regexp_replace(new.indexdef, E'.*USING','')
        ORDER BY old.indexdef, new.indexdef
    LOOP
      IF bDDLOnly THEN
        RAISE INFO '%', 'ALTER INDEX ' || quote_ident(dest_schema) || '.'  || quote_ident(ix_new_name) || ' RENAME TO ' || quote_ident(ix_old_name) || ';';
      ELSE
        -- The SELECT query above may return duplicate names when a column is
        -- indexed twice the same manner with 2 different names. Therefore, to
        -- avoid a 'relation "xxx" already exists' we test if the index name
        -- is in use or free. Skipping existing index will fallback on unused
        -- ones and every duplicate will be mapped to distinct old names.
        IF NOT EXISTS (
            SELECT TRUE
            FROM pg_indexes
            WHERE schemaname = dest_schema
              AND tablename = tblname
              AND indexname = quote_ident(ix_old_name))
          AND EXISTS (
            SELECT TRUE
            FROM pg_indexes
            WHERE schemaname = dest_schema
              AND tablename = tblname
              AND indexname = quote_ident(ix_new_name))
          THEN
          EXECUTE 'ALTER INDEX ' || quote_ident(dest_schema) || '.' || quote_ident(ix_new_name) || ' RENAME TO ' || quote_ident(ix_old_name) || ';';
        END IF;
      END IF;
    END LOOP;

    lastsql = '';
    IF bData THEN
      -- Insert records from source table

      -- 2021-03-03  MJV FIX
      buffer := dest_schema || '.' || quote_ident(tblname);

      -- 2020/06/18 - Issue #31 fix: add "OVERRIDING SYSTEM VALUE" for IDENTITY columns marked as GENERATED ALWAYS.
      select count(*) into cnt2 from pg_class c, pg_attribute a, pg_namespace n
          where a.attrelid = c.oid and c.relname = quote_ident(tblname) and n.oid = c.relnamespace and n.nspname = quote_ident(source_schema) and a.attidentity = 'a';
      buffer3 := '';
      IF cnt2 > 0 THEN
          buffer3 := ' OVERRIDING SYSTEM VALUE';
      END IF;
      -- BUG for inserting rows from tables with user-defined columns
      -- INSERT INTO sample_clone.address OVERRIDING SYSTEM VALUE SELECT * FROM sample.address;
      -- ERROR:  column "id2" is of type sample_clone.udt_myint but expression is of type udt_myint
      
      -- Issue#86 fix:
      -- IF data_type = 'USER-DEFINED' THEN
      IF bDebug THEN RAISE NOTICE 'DEBUG: includerecs branch  table=%  data_type=%  isgenerated=%  buffer3=%', tblname, data_type, isGenerated, buffer3; END IF;
      IF data_type = 'USER-DEFINED' OR isGenerated = 'ALWAYS' THEN

        -- RAISE WARNING 'Bypassing copying rows for table (%) with user-defined data types.  You must copy them manually.', tblname;
        -- wont work --> INSERT INTO clone1.address (id2, id3, addr) SELECT cast(id2 as clone1.udt_myint), cast(id3 as clone1.udt_myint), addr FROM sample.address;
        -- Issue#101 --> INSERT INTO clone1.address2 (id2, id3, addr) SELECT id2::text::clone1.udt_myint, id3::text::clone1.udt_myint, addr FROM sample.address; 

        -- Issue#79 implementation follows        
        -- COPY sample.statuses(id, s) TO '/tmp/statuses.txt' WITH DELIMITER AS ',';
        -- COPY sample_clone1.statuses FROM '/tmp/statuses.txt' (DELIMITER ',', NULL '');
        -- Issue#101 fix: use text cast to get around the problem.
        IF bFileCopy THEN
          IF bWindows THEN
              buffer2   := 'COPY ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' TO  ''C:\WINDOWS\TEMP\cloneschema.tmp'' WITH DELIMITER AS '','';';
              tblarray2 := tblarray2 || buffer2;
              -- Issue #81 reformat COPY command for upload
              -- buffer2:= 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM  ''C:\WINDOWS\TEMP\cloneschema.tmp'' (DELIMITER '','', NULL '''');';
              buffer2   := 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM  ''C:\WINDOWS\TEMP\cloneschema.tmp'' (DELIMITER '','', NULL ''\N'', FORMAT CSV);';
              tblarray2 := tblarray2 || buffer2;
          ELSE
              buffer2   := 'COPY ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' TO ''/tmp/cloneschema.tmp'' WITH DELIMITER AS '','';';
              tblarray2 := tblarray2 || buffer2;
              -- Issue #81 reformat COPY command for upload
              -- buffer2   := 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM ''/tmp/cloneschema.tmp'' (DELIMITER '','', NULL '''');';
              -- works--> COPY sample.timestamptbl2  FROM '/tmp/cloneschema.tmp' WITH (DELIMITER ',', NULL '\N', FORMAT CSV) ;
              buffer2   := 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM ''/tmp/cloneschema.tmp'' (DELIMITER '','', NULL ''\N'', FORMAT CSV);';
              tblarray2 := tblarray2 || buffer2;
          END IF;
        ELSE
          -- Issue#101: assume direct copy with text cast, add to separate array
          SELECT * INTO buffer3 FROM public.get_insert_stmt_ddl(quote_ident(source_schema), quote_ident(dest_schema), quote_ident(tblname), True);
          tblarray3 := tblarray3 || buffer3;
        END IF;
      ELSE
        -- bypass child tables since we populate them when we populate the parents
        IF bDebug THEN RAISE NOTICE 'DEBUG: tblname=%  bRelispart=%  relknd=%  l_child=%  bChild=%', tblname, bRelispart, relknd, l_child, bChild; END IF;
        IF NOT bRelispart AND NOT bChild THEN
          -- Issue#75: Must defer population of tables until child tables have been added to parents
          -- Issue#101 Offer alternative of copy to/from file. Although originally intended for tables with UDTs, it is now expanded to handle all cases for performance improvement perhaps for large tables.
          -- Issue#106 buffer3 shouldnt be in the mix
          -- revisited:  buffer3 should be in play for PG versions that handle IDENTITIES
          buffer2 := 'INSERT INTO ' || buffer || buffer3 || ' SELECT * FROM ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ';';
          -- buffer2 := 'INSERT INTO ' || buffer || ' SELECT * FROM ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ';';
          IF bDebug THEN RAISE NOTICE 'DEBUG: buffer2=%',buffer2; END IF;
          IF bFileCopy THEN
            tblarray2:= tblarray2 || buffer2;
          ELSE
            tblarray := tblarray || buffer2;
          END IF;
        END IF;
      END IF;
    END IF;

    -- Issue#61 FIX: use set_config for empty string
    -- SET search_path = '';
    SELECT set_config('search_path', '', false) into v_dummy;

    FOR column_, default_ IN
      SELECT column_name::text,
             REPLACE(column_default::text, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.')
      FROM information_schema.COLUMNS
      WHERE table_schema = source_schema
          AND TABLE_NAME = tblname
          AND column_default LIKE 'nextval(%' || quote_ident(source_schema) || '%::regclass)'
    LOOP
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on column name
      buffer2 = 'ALTER TABLE ' || buffer || ' ALTER COLUMN ' || quote_ident(column_) || ' SET DEFAULT ' || default_ || ';';
      IF bDDLOnly THEN
        -- May need to come back and revisit this since previous sql will not return anything since no schema as created!
        RAISE INFO '%', buffer2;
      ELSE
        lastsql = buffer2;
        EXECUTE buffer2;
        lastsql = '';
      END IF;
    END LOOP;
    
    EXECUTE 'SET search_path = ' || quote_ident(source_schema) ;
  END LOOP;
  ELSE 
  -- Handle 9.6 versions 90600
  FOR tblname, relpersist, relknd, data_type, udt_name, udt_schema, ocomment, l_child, isGenerated, tblowner, tblspace  IN
    -- 2021-03-08 MJV #39 fix: change sql to get indicator of user-defined columns to issue warnings
    -- select c.relname, c.relpersistence, c.relispartition, c.relkind
    -- FROM pg_class c, pg_namespace n where n.oid = c.relnamespace and n.nspname = quote_ident(source_schema) and c.relkind in ('r','p') and
    -- order by c.relkind desc, c.relname
    --Fix#65 add another left join to distinguish child tables by inheritance
    -- Fix#86 add is_generated to column select
    -- Fix#91 add tblowner to the select
    -- Fix#105 need a different kinda distint to avoid retrieving a table twice in the case of a table with multiple USER-DEFINED datatypes using DISTINCT ON instead of just DISTINCT
    -- Fixed Issue#108: double quote roles to avoid problems with special characters in OWNER TO statements
    --SELECT DISTINCT c.relname, c.relpersistence, c.relispartition, c.relkind, co.data_type, co.udt_name, co.udt_schema, obj_description(c.oid), i.inhrelid, 
    --                COALESCE(co.is_generated, ''), pg_catalog.pg_get_userbyid(c.relowner) as "Owner", CASE WHEN reltablespace = 0 THEN 'pg_default' ELSE ts.spcname END as tablespace
    -- SELECT DISTINCT ON (c.relname, c.relpersistence, c.relkind, co.data_type) c.relname, c.relpersistence, c.relkind, co.data_type, co.udt_name, co.udt_schema, obj_description(c.oid), i.inhrelid, 
    --                 COALESCE(co.is_generated, ''), pg_catalog.pg_get_userbyid(c.relowner) as "Owner", CASE WHEN reltablespace = 0 THEN 'pg_default' ELSE ts.spcname END as tablespace                    
    SELECT DISTINCT ON (c.relname, c.relpersistence, c.relkind, co.data_type) c.relname, c.relpersistence, c.relkind, co.data_type, co.udt_name, co.udt_schema, obj_description(c.oid), i.inhrelid, 
                    COALESCE(co.is_generated, ''), '"' || pg_catalog.pg_get_userbyid(c.relowner) || '"' as "Owner", CASE WHEN reltablespace = 0 THEN 'pg_default' ELSE ts.spcname END as tablespace                    
    FROM pg_class c
        JOIN pg_namespace n ON (n.oid = c.relnamespace
                AND n.nspname = quote_ident(source_schema)
                AND c.relkind IN ('r', 'p'))
        LEFT JOIN information_schema.columns co ON (co.table_schema = n.nspname
                AND co.table_name = c.relname
                AND (co.data_type = 'USER-DEFINED' OR co.is_generated = 'ALWAYS'))
        LEFT JOIN pg_inherits i ON (c.oid = i.inhrelid) 
        -- issue#99 added join
        LEFT JOIN pg_tablespace ts ON (c.reltablespace = ts.oid) 
    ORDER BY c.relkind DESC, c.relname
  LOOP
    cnt := cnt + 1;
    IF l_child IS NULL THEN
      bChild := False;
    ELSE
      bChild := True;
    END IF;
    IF bDebug THEN RAISE NOTICE 'DEBUG: TABLE START --> table=%  bRelispart=NA  relkind=%  bChild=%',tblname, relknd, bChild; END IF;

    IF data_type = 'USER-DEFINED' THEN
      -- RAISE NOTICE ' Table (%) has column(s) with user-defined types so using get_table_ddl() instead of CREATE TABLE LIKE construct.',tblname;
      cnt :=cnt;
    END IF;
    buffer := quote_ident(dest_schema) || '.' || quote_ident(tblname);
    buffer2 := '';
    IF relpersist = 'u' THEN
      buffer2 := 'UNLOGGED ';
    END IF;
    IF relknd = 'r' THEN
      IF bDDLOnly THEN
        IF data_type = 'USER-DEFINED' THEN
          -- FIXED #65, #67
          -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
          -- FIX: #121 Use pg_get_tabledef instead
          -- SELECT * INTO buffer3 FROM public.get_table_ddl(quote_ident(source_schema), tblname, False);
          SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
          buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
          RAISE INFO '%', buffer3;
          -- issue#91 fix
          -- issue#95
          IF NOT bNoOwner THEN    
            -- Fixed Issue#108: double-quote roles in case they have special characters
            RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || tblname, tblowner;
          END IF;
        ELSE
          IF NOT bChild THEN
            RAISE INFO '%', 'CREATE ' || buffer2 || 'TABLE ' || buffer || ' (LIKE ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' INCLUDING ALL);';
            -- issue#91 fix
             -- issue#95
            IF NOT bNoOwner THEN    
              -- Fixed Issue#108: double-quote roles in case they have special characters
              RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || tblname, tblowner;
            END IF;
            
            -- issue#99 
            IF tblspace <> 'pg_default' THEN
              -- replace with user-defined tablespace
              -- ALTER TABLE myschema.mytable SET TABLESPACE usrtblspc;
              RAISE INFO 'ALTER TABLE IF EXISTS % SET TABLESPACE %;', quote_ident(dest_schema) || '.' || tblname, tblspace;
            END IF;
          ELSE
            -- FIXED #65, #67
            -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
            -- FIX: #121 Use pg_get_tabledef instead
            -- SELECT * INTO buffer3 FROM public.get_table_ddl(quote_ident(source_schema), tblname, False);
            SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
            buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
            RAISE INFO '%', buffer3;
            -- issue#91 fix
            -- issue#95
            IF NOT bNoOwner THEN    
              -- Fixed Issue#108: double-quote roles in case they have special characters
              RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || tblname, tblowner;
            END IF;
          END IF;
        END IF;
      ELSE
        IF data_type = 'USER-DEFINED' THEN
          -- FIXED #65, #67
          -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
          -- FIX: #121 Use pg_get_tabledef instead
          -- SELECT * INTO buffer3 FROM public.get_table_ddl(quote_ident(source_schema), tblname, False);
          SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
          buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
          IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef01b:%', buffer3; END IF;
          -- #82: Table def should be fully qualified with target schema, 
          --      so just make search path = public to handle extension types that should reside in public schema
          v_dummy = 'public';
          SELECT set_config('search_path', v_dummy, false) into v_dummy;
          lastsql = buffer3;
          EXECUTE buffer3;
          lastsql = '';
          -- issue#91 fix
          -- issue#95
          IF NOT bNoOwner THEN    
            -- Fixed Issue#108: double-quote roles in case they have special characters
            buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || tblname || ' OWNER TO ' || tblowner;
            lastsql = buffer3;
            EXECUTE buffer3;
            lastsql = '';
          END IF;
        ELSE
          IF (NOT bChild) THEN
            buffer3 := 'CREATE ' || buffer2 || 'TABLE ' || buffer || ' (LIKE ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' INCLUDING ALL)';
            IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef02:%', buffer3; END IF;
            lastsql = buffer3;
            EXECUTE buffer3;
            lastsql = '';
            -- issue#91 fix
            -- issue#95
            IF NOT bNoOwner THEN    
              -- Fixed Issue#108: double-quote roles in case they have special characters
              buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.'  || quote_ident(tblname) || ' OWNER TO ' || tblowner;
              lastsql = buffer3;
              EXECUTE buffer3;
              lastsql = '';
            END IF;
            
            -- issue#99
            IF tblspace <> 'pg_default' THEN
              -- replace with user-defined tablespace
              -- ALTER TABLE myschema.mytable SET TABLESPACE usrtblspc;
              buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || tblname || ' SET TABLESPACE ' || tblspace;
              lastsql = buffer3;
              EXECUTE buffer3;
              lastsql = '';
            END IF;

          ELSE
            -- FIXED #65, #67
            -- SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname);
           
            -- FIX: #121 Use pg_get_tabledef instead
            -- SELECT * INTO buffer3 FROM public.get_table_ddl(quote_ident(source_schema), tblname, False);
            SELECT * INTO buffer3 FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
            buffer3 := REPLACE(buffer3, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
            -- set client_min_messages higher to avoid messages like this:
            -- NOTICE:  merging column "city_id" with inherited definition
            set client_min_messages = 'WARNING';
            IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef03:%', buffer3; END IF;
            lastsql = buffer3;
            EXECUTE buffer3;
            lastsql = '';
            -- issue#91 fix
            -- issue#95
            IF NOT bNoOwner THEN
              -- Fixed Issue#108: double-quote roles in case they have special characters
              buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || tblname || ' OWNER TO ' || tblowner;
              lastsql = buffer3;
              EXECUTE buffer3;
              lastsql = '';
            END IF;

            -- reset it back, only get these for inheritance-based tables
            set client_min_messages = 'notice';
          END IF;
        END IF;
        -- Add table comment.
        IF ocomment IS NOT NULL THEN
          EXECUTE 'COMMENT ON TABLE ' || buffer || ' IS ' || quote_literal(ocomment);
        END IF;
      END IF;
    ELSIF relknd = 'p' THEN
      -- define parent table and assume child tables have already been created based on top level sort order.
      -- Issue #103 Put the complex query into its own function, get_table_ddl_complex()
      
      -- FIX: #121 Use pg_get_tabledef instead
      -- SELECT * INTO qry FROM public.get_table_ddl_complex(source_schema, dest_schema, tblname, sq_server_version_num);
      SELECT * INTO qry FROM public.pg_get_tabledef(quote_ident(source_schema), tblname, false, 'FKEYS_NONE');                      
      qry := REPLACE(qry, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
      
      IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef04 - %', buffer; END IF;
      
      IF bDDLOnly THEN
        RAISE INFO '%', qry;
        -- issue#95
        IF NOT bNoOwner THEN
            -- Fixed Issue#108: double-quote roles in case they have special characters
            RAISE INFO 'ALTER TABLE IF EXISTS % OWNER TO %;', quote_ident(dest_schema) || '.' || quote_ident(tblname), tblowner;
        END IF;
      ELSE
        -- Issue#103: we need to always set search_path priority to target schema when we execute DDL
        IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef04 context: old search path=%  new search path=% current search path=%', src_path_old, src_path_new, v_dummy; END IF;
        SELECT setting INTO spath_tmp FROM pg_settings WHERE name = 'search_path';   
        IF spath_tmp <> dest_schema THEN
          -- change it to target schema and don't forget to change it back after we execute the DDL
          spath = 'SET search_path = "' || dest_schema || '"';
          IF bDebug THEN RAISE NOTICE 'DEBUG: changing search_path --> %', spath; END IF;
          EXECUTE spath;
          SELECT setting INTO v_dummy FROM pg_settings WHERE name = 'search_path';   
          IF bDebug THEN RAISE NOTICE 'DEBUG: search_path changed to %', v_dummy; END IF;
        END IF;
        IF bDebug THEN RAISE NOTICE 'DEBUG: tabledef04:%', qry; END IF;
        lastsql = qry;
        EXECUTE qry;
        lastsql = '';
        
        -- Issue#103
        -- Set search path back to what it was
        spath = 'SET search_path = "' || spath_tmp || '"';
        EXECUTE spath;
        SELECT setting INTO v_dummy FROM pg_settings WHERE name = 'search_path';   
        IF bDebug THEN RAISE NOTICE 'DEBUG: search_path changed back to %', v_dummy; END IF;
        
        -- issue#91 fix
        -- issue#95
        IF NOT bNoOwner THEN
          -- Fixed Issue#108: double-quote roles in case they have special characters
          buffer3 = 'ALTER TABLE IF EXISTS ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || ' OWNER TO ' || tblowner;
          EXECUTE buffer3;
        END IF;
        
      END IF;
      -- loop for child tables and alter them to attach to parent for specific partition method.
      -- Issue#103 fix: only loop for the table we are currently processing, tblname!
      FOR aname, part_range, object IN
        SELECT quote_ident(dest_schema) || '.' || c1.relname as tablename, pg_catalog.pg_get_expr(c1.relpartbound, c1.oid) as partrange, quote_ident(dest_schema) || '.' || c2.relname as object
        FROM pg_catalog.pg_class c1, pg_namespace n, pg_catalog.pg_inherits i, pg_class c2
        WHERE n.nspname = quote_ident(source_schema) AND c1.relnamespace = n.oid AND c1.relkind = 'r' 
        -- Issue#103: added this condition to only work on current partitioned table.  The problem was regression testing previously only worked on one partition table clone case
        AND c2.relname = tblname AND 
        c1.relispartition AND c1.oid=i.inhrelid AND i.inhparent = c2.oid AND c2.relnamespace = n.oid ORDER BY pg_catalog.pg_get_expr(c1.relpartbound, c1.oid) = 'DEFAULT',
        c1.oid::pg_catalog.regclass::pg_catalog.text
      LOOP
        qry := 'ALTER TABLE ONLY ' || object || ' ATTACH PARTITION ' || aname || ' ' || part_range || ';';
        IF bDebug THEN RAISE NOTICE 'DEBUG: %',qry; END IF;
        -- issue#91, not sure if we need to do this for child tables
        -- issue#95 we dont set ownership here
        IF bDDLOnly THEN
          RAISE INFO '%', qry;
          IF NOT bNoOwner THEN
            NULL;
          END IF;
        ELSE
          lastsql = qry;
          EXECUTE qry;
          lastsql = '';
          IF NOT bNoOwner THEN
            NULL;
          END IF;
        END IF;
      END LOOP;
    END IF;
        
    -- INCLUDING ALL creates new index names, we restore them to the old name.
    -- There should be no conflicts since they live in different schemas
    FOR ix_old_name, ix_new_name IN
      SELECT old.indexname, new.indexname
      FROM pg_indexes old, pg_indexes new
      WHERE old.schemaname = source_schema
        AND new.schemaname = dest_schema
        AND old.tablename = new.tablename
        AND old.tablename = tblname
        AND old.indexname <> new.indexname
        AND regexp_replace(old.indexdef, E'.*USING','') = regexp_replace(new.indexdef, E'.*USING','')
        ORDER BY old.indexdef, new.indexdef
    LOOP
      lastsql = '';
      IF bDDLOnly THEN
        RAISE INFO '%', 'ALTER INDEX ' || quote_ident(dest_schema) || '.'  || quote_ident(ix_new_name) || ' RENAME TO ' || quote_ident(ix_old_name) || ';';
      ELSE
        -- The SELECT query above may return duplicate names when a column is
        -- indexed twice the same manner with 2 different names. Therefore, to
        -- avoid a 'relation "xxx" already exists' we test if the index name
        -- is in use or free. Skipping existing index will fallback on unused
        -- ones and every duplicate will be mapped to distinct old names.
        IF NOT EXISTS (
            SELECT TRUE
            FROM pg_indexes
            WHERE schemaname = dest_schema
              AND tablename = tblname
              AND indexname = quote_ident(ix_old_name))
          AND EXISTS (
            SELECT TRUE
            FROM pg_indexes
            WHERE schemaname = dest_schema
              AND tablename = tblname
              AND indexname = quote_ident(ix_new_name))
          THEN
          EXECUTE 'ALTER INDEX ' || quote_ident(dest_schema) || '.' || quote_ident(ix_new_name) || ' RENAME TO ' || quote_ident(ix_old_name) || ';';
        END IF;
      END IF;
    END LOOP;

    IF bData THEN
      -- Insert records from source table

      -- 2021-03-03  MJV FIX
      buffer := dest_schema || '.' || quote_ident(tblname);
      
      -- Issue#86 fix:
      -- IF data_type = 'USER-DEFINED' THEN
      IF bDebug THEN RAISE NOTICE 'DEBUG: includerecs branch  table=%  data_type=%  isgenerated=%', tblname, data_type, isGenerated; END IF;
      IF data_type = 'USER-DEFINED' OR isGenerated = 'ALWAYS' THEN

        -- RAISE WARNING 'Bypassing copying rows for table (%) with user-defined data types.  You must copy them manually.', tblname;
        -- wont work --> INSERT INTO clone1.address (id2, id3, addr) SELECT cast(id2 as clone1.udt_myint), cast(id3 as clone1.udt_myint), addr FROM sample.address;
        -- Issue#101 --> INSERT INTO clone1.address2 (id2, id3, addr) SELECT id2::text::clone1.udt_myint, id3::text::clone1.udt_myint, addr FROM sample.address; 

        -- Issue#79 implementation follows        
        -- COPY sample.statuses(id, s) TO '/tmp/statuses.txt' WITH DELIMITER AS ',';
        -- COPY sample_clone1.statuses FROM '/tmp/statuses.txt' (DELIMITER ',', NULL '');
        -- Issue#101 fix: use text cast to get around the problem.
        IF bFileCopy THEN
          IF bWindows THEN
              buffer2   := 'COPY ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' TO  ''C:\WINDOWS\TEMP\cloneschema.tmp'' WITH DELIMITER AS '','';';
              tblarray2 := tblarray2 || buffer2;
              -- Issue #81 reformat COPY command for upload
              -- buffer2:= 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM  ''C:\WINDOWS\TEMP\cloneschema.tmp'' (DELIMITER '','', NULL '''');';
              buffer2   := 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM  ''C:\WINDOWS\TEMP\cloneschema.tmp'' (DELIMITER '','', NULL ''\N'', FORMAT CSV);';
              tblarray2 := tblarray2 || buffer2;
          ELSE
              buffer2   := 'COPY ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ' TO ''/tmp/cloneschema.tmp'' WITH DELIMITER AS '','';';
              tblarray2 := tblarray2 || buffer2;
              -- Issue #81 reformat COPY command for upload
              -- buffer2   := 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM ''/tmp/cloneschema.tmp'' (DELIMITER '','', NULL '''');';
              -- works--> COPY sample.timestamptbl2  FROM '/tmp/cloneschema.tmp' WITH (DELIMITER ',', NULL '\N', FORMAT CSV) ;
              buffer2   := 'COPY ' || quote_ident(dest_schema) || '.' || quote_ident(tblname) || '  FROM ''/tmp/cloneschema.tmp'' (DELIMITER '','', NULL ''\N'', FORMAT CSV);';
              tblarray2 := tblarray2 || buffer2;
          END IF;
        ELSE
          -- Issue#101: assume direct copy with text cast, add to separate array
          SELECT * INTO buffer3 FROM public.get_insert_stmt_ddl(quote_ident(source_schema), quote_ident(dest_schema), quote_ident(tblname), True);
          tblarray3 := tblarray3 || buffer3;
        END IF;
      ELSE
        -- bypass child tables since we populate them when we populate the parents
        IF bDebug THEN RAISE NOTICE 'DEBUG: tblname=%  bRelispart=NA relknd=%  l_child=%  bChild=%', tblname, relknd, l_child, bChild; END IF;

        IF NOT bChild THEN
          -- Issue#75: Must defer population of tables until child tables have been added to parents
          -- Issue#101 Offer alternative of copy to/from file. Although originally intended for tables with UDTs, it is now expanded to handle all cases for performance improvement perhaps for large tables.
          -- buffer2 := 'INSERT INTO ' || buffer || buffer3 || ' SELECT * FROM ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ';';
          buffer2 := 'INSERT INTO ' || buffer || ' SELECT * FROM ' || quote_ident(source_schema) || '.' || quote_ident(tblname) || ';';
          IF bDebug THEN RAISE NOTICE 'DEBUG: buffer2=%',buffer2; END IF;
          IF bFileCopy THEN
            tblarray2:= tblarray2 || buffer2;
          ELSE
            tblarray := tblarray || buffer2;
          END IF;
        END IF;
      END IF;
    END IF;

    -- Issue#61 FIX: use set_config for empty string
    -- SET search_path = '';
    SELECT set_config('search_path', '', false) into v_dummy;

    FOR column_, default_ IN
      SELECT column_name::text,
             REPLACE(column_default::text, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.')
      FROM information_schema.COLUMNS
      WHERE table_schema = source_schema
          AND TABLE_NAME = tblname
          AND column_default LIKE 'nextval(%' || quote_ident(source_schema) || '%::regclass)'
    LOOP
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on column name
      buffer2 = 'ALTER TABLE ' || buffer || ' ALTER COLUMN ' || quote_ident(column_) || ' SET DEFAULT ' || default_ || ';';
      IF bDDLOnly THEN
        -- May need to come back and revisit this since previous sql will not return anything since no schema as created!
        RAISE INFO '%', buffer2;
      ELSE
        lastsql = buffer2;
        EXECUTE buffer2;
        lastsql = '';
      END IF;
    END LOOP;
    
    EXECUTE 'SET search_path = ' || quote_ident(source_schema) ;
  END LOOP;      
  END IF;
  -- end of 90600 branch
  
  RAISE NOTICE '      TABLES cloned: %', LPAD(cnt::text, 5, ' ');

  SELECT setting INTO v_dummy FROM pg_settings WHERE name = 'search_path';
  IF bDebug THEN RAISE NOTICE 'DEBUG: search_path=%', v_dummy; END IF;

  -- Assigning sequences to table columns.
  action := 'Sequences assigning';
  cnt := 0;
  FOR object IN
    SELECT sequence_name::text
    FROM information_schema.sequences
    WHERE sequence_schema = quote_ident(source_schema)
  LOOP
    cnt := cnt + 1;
    srctbl := quote_ident(source_schema) || '.' || quote_ident(object);

    -- Get owning column, inspired from Sadique Ali post at:
    -- https://sadique.io/blog/2019/05/07/viewing-sequence-ownership-information-in-postgres/
    -- Fixed via pull request#109
    SELECT ' OWNED BY '
      || quote_ident(dest_schema)
      || '.'
      || quote_ident(dc.relname)
      || '.'
      || quote_ident(a.attname)
    INTO sq_owned
    FROM pg_class AS c
      JOIN pg_namespace n ON c.relnamespace = n.oid
      JOIN pg_depend AS d ON c.relfilenode = d.objid
      JOIN pg_class AS dc ON (
        d.refobjid = dc.relfilenode
        AND dc.relnamespace = n.oid
      )
      JOIN pg_attribute AS a ON (
        a.attnum = d.refobjsubid
        AND a.attrelid = d.refobjid
      )
    WHERE n.nspname = quote_ident(source_schema)
      AND c.relkind = 'S'
      AND c.relname = object;

    IF sq_owned IS NOT NULL THEN
      qry := 'ALTER SEQUENCE '
        || quote_ident(dest_schema)
        || '.'
        || quote_ident(object)
        || sq_owned
        || ';';

      IF bDDLOnly THEN
        RAISE NOTICE 'DEBUG: %',qry;
        RAISE INFO '%', qry;
      ELSE
        lastsql = qry;
        EXECUTE qry;
        lastsql = '';
      END IF;

    END IF;

  END LOOP;
  RAISE NOTICE '    SEQUENCES set:   %', LPAD(cnt::text, 5, ' ');

  -- Update IDENTITY sequences to the last value, bypass 9.6 versions
  IF sq_server_version_num > 90624 THEN
      action := 'Identity updating';
      cnt := 0;
      FOR object, sq_last_value IN
        SELECT sequencename::text, COALESCE(last_value, -999) from pg_sequences where schemaname = quote_ident(source_schema)
        AND NOT EXISTS
        (select 1 from information_schema.sequences where sequence_schema = quote_ident(source_schema) and sequence_name = sequencename)
      LOOP
        IF sq_last_value = -999 THEN
          continue;
        END IF;
        cnt := cnt + 1;
        buffer := quote_ident(dest_schema) || '.' || quote_ident(object);
        IF bData THEN
          EXECUTE 'SELECT setval( ''' || buffer || ''', ' || sq_last_value || ', ' || sq_is_called || ');' ;
        ELSE
          if bDDLOnly THEN
            -- fix#63
            RAISE INFO '%', 'SELECT setval( ''' || buffer || ''', ' || sq_last_value || ', ' || sq_is_called || ');' ;
          ELSE
            -- fix#63
            EXECUTE 'SELECT setval( ''' || buffer || ''', ' || sq_last_value || ', ' || sq_is_called || ');' ;
          END IF;
        END IF;
      END LOOP;
      -- Fixed Issue#107: set lpad from 2 to 5
      RAISE NOTICE '   IDENTITIES set:   %', LPAD(cnt::text, 5, ' ');
  ELSE
    -- Fixed Issue#107: set lpad from 2 to 5
    RAISE NOTICE '   IDENTITIES set:   %', LPAD('-1'::text, 5, ' ');    
  END IF;

  -- Issue#78 forces us to defer FKeys until the end since we previously did row copies before FKeys
  --  add FK constraint
  -- action := 'FK Constraints';

  -- Issue#62: Add comments on indexes, and then removed them from here and reworked later below.

  -- Issue 90: moved functions to here, before views or MVs that might use them
  -- Create functions
    action := 'Functions';
    cnt := 0;
    -- MJV FIX per issue# 34
    -- SET search_path = '';
    EXECUTE 'SET search_path = ' || quote_ident(source_schema) ;
    
    -- Fixed Issue#65
    -- Fixed Issue#97
    -- FOR func_oid IN SELECT oid FROM pg_proc WHERE pronamespace = src_oid AND prokind != 'a'
    IF is_prokind THEN
      FOR func_oid, func_owner, func_name, func_args, func_argno, buffer3 IN 
          SELECT p.oid, pg_catalog.pg_get_userbyid(p.proowner), p.proname, oidvectortypes(p.proargtypes), p.pronargs,
          CASE WHEN prokind = 'p' THEN 'PROCEDURE' WHEN prokind = 'f' THEN 'FUNCTION' ELSE '' END 
          FROM pg_proc p WHERE p.pronamespace = src_oid AND p.prokind != 'a'          
      LOOP
        cnt := cnt + 1;
        SELECT pg_get_functiondef(func_oid)
        INTO qry;
  
        SELECT replace(qry, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.') INTO dest_qry;
        IF bDDLOnly THEN
          RAISE INFO '%;', dest_qry;
          -- Issue#91 Fix
          -- issue#95 
          IF NOT bNoOwner THEN
            IF func_argno = 0 THEN
                -- Fixed Issue#108: double-quote roles in case they have special characters
                RAISE INFO 'ALTER % %() OWNER TO %', buffer3, quote_ident(dest_schema) || '.' || quote_ident(func_name), '"' || func_owner || '";';
            ELSE
                -- Fixed Issue#108: double-quote roles in case they have special characters
                RAISE INFO 'ALTER % % OWNER TO %', buffer3, quote_ident(dest_schema) || '.' || quote_ident(func_name) || '(' || func_args || ')', '"' || func_owner || '";';
            END IF;
          END IF;
        ELSE
          IF bDebug THEN RAISE NOTICE 'DEBUG: %', dest_qry; END IF;
          lastsql = dest_qry;
          EXECUTE dest_qry;
          lastsql = '';

          -- Issue#91 Fix
          -- issue#95 
          IF NOT bNoOwner THEN
            IF func_argno = 0 THEN
                -- Fixed Issue#108: double-quote roles in case they have special characters
                dest_qry = 'ALTER ' || buffer3 || ' ' || quote_ident(dest_schema) || '.' || quote_ident(func_name) || '() OWNER TO ' || '"' || func_owner || '";';
            ELSE
                -- Fixed Issue#108: double-quote roles in case they have special characters
                dest_qry = 'ALTER ' || buffer3 || ' ' || quote_ident(dest_schema) || '.' || quote_ident(func_name) || '(' || func_args || ') OWNER TO ' || '"' || func_owner || '";';
            END IF;
          END IF;
          lastsql = dest_qry;
          EXECUTE dest_qry;
          lastsql = '';
        END IF;
      END LOOP;
    ELSE
      FOR func_oid IN SELECT oid
                      FROM pg_proc
                      WHERE pronamespace = src_oid AND not proisagg
      LOOP
        cnt := cnt + 1;
        SELECT pg_get_functiondef(func_oid) INTO qry;
        SELECT replace(qry, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.') INTO dest_qry;
        IF bDDLOnly THEN
          RAISE INFO '%;', dest_qry;
        ELSE
          lastsql = dest_qry;
          EXECUTE dest_qry;
          lastsql = '';
        END IF;
      END LOOP;
    END IF;
  
    -- Create aggregate functions.
    -- Fixed Issue#65
    -- FOR func_oid IN SELECT oid FROM pg_proc WHERE pronamespace = src_oid AND prokind = 'a'
    IF is_prokind THEN
      FOR func_oid IN
          SELECT oid
          FROM pg_proc
          WHERE pronamespace = src_oid AND prokind = 'a'
      LOOP
        cnt := cnt + 1;
        SELECT
          'CREATE AGGREGATE '
          || dest_schema
          || '.'
          || p.proname
          || '('
          -- || format_type(a.aggtranstype, NULL)
          -- Issue#65 Fixes for specific datatype mappings
          || CASE WHEN format_type(a.aggtranstype, NULL) = 'double precision[]' THEN 'float8'
                  WHEN format_type(a.aggtranstype, NULL) = 'anyarray'           THEN 'anyelement'
             ELSE format_type(a.aggtranstype, NULL) END
          || ') (sfunc = '
          || regexp_replace(a.aggtransfn::text, '(^|\W)' || quote_ident(source_schema) || '\.', '\1' || quote_ident(dest_schema) || '.')
          || ', stype = '
          -- || format_type(a.aggtranstype, NULL)
          -- Issue#65 Fixes for specific datatype mappings
          || CASE WHEN format_type(a.aggtranstype, NULL) = 'double precision[]' THEN 'float8[]' ELSE format_type(a.aggtranstype, NULL) END
          || CASE
              WHEN op.oprname IS NULL THEN ''
              ELSE ', sortop = ' || op.oprname
            END
          || CASE
              WHEN a.agginitval IS NULL THEN ''
              ELSE ', initcond = ''' || a.agginitval || ''''
            END
          || ')'
        INTO dest_qry
        FROM pg_proc p
        JOIN pg_aggregate a ON a.aggfnoid = p.oid
        LEFT JOIN pg_operator op ON op.oid = a.aggsortop
        WHERE p.oid = func_oid;
  
        IF bDDLOnly THEN
          RAISE INFO '%;', dest_qry;
        ELSE
          lastsql = dest_qry;
          EXECUTE dest_qry;
          lastsql = '';
        END IF;
  
      END LOOP;
      RAISE NOTICE '   FUNCTIONS cloned: %', LPAD(cnt::text, 5, ' ');
  
    ELSE
      FOR func_oid IN SELECT oid FROM pg_proc WHERE pronamespace = src_oid AND proisagg
      LOOP
        cnt := cnt + 1;
        SELECT
          'CREATE AGGREGATE '
          || dest_schema
          || '.'
          || p.proname
          || '('
          -- || format_type(a.aggtranstype, NULL)
          -- Issue#65 Fixes for specific datatype mappings
          || CASE WHEN format_type(a.aggtranstype, NULL) = 'double precision[]' THEN 'float8'
                  WHEN format_type(a.aggtranstype, NULL) = 'anyarray'           THEN 'anyelement'
             ELSE format_type(a.aggtranstype, NULL) END
          || ') (sfunc = '
          || regexp_replace(a.aggtransfn::text, '(^|\W)' || quote_ident(source_schema) || '\.', '\1' || quote_ident(dest_schema) || '.')
          || ', stype = '
          -- || format_type(a.aggtranstype, NULL)
          -- Issue#65 Fixes for specific datatype mappings
          || CASE WHEN format_type(a.aggtranstype, NULL) = 'double precision[]' THEN 'float8[]' ELSE format_type(a.aggtranstype, NULL) END
          || CASE
              WHEN op.oprname IS NULL THEN ''
              ELSE ', sortop = ' || op.oprname
            END
          || CASE
              WHEN a.agginitval IS NULL THEN ''
              ELSE ', initcond = ''' || a.agginitval || ''''
            END
          || ')'
        INTO dest_qry
        FROM pg_proc p
        JOIN pg_aggregate a ON a.aggfnoid = p.oid
        LEFT JOIN pg_operator op ON op.oid = a.aggsortop
        WHERE p.oid = func_oid;
  
        IF bDDLOnly THEN
          RAISE INFO '%;', dest_qry;
        ELSE
          lastsql = dest_qry;
          EXECUTE dest_qry;
          lastsql = '';
        END IF;
  
      END LOOP;
      RAISE NOTICE '   FUNCTIONS cloned: %', LPAD(cnt::text, 5, ' ');
    END IF;
  
  -- Create views
  action := 'Views';

  -- Issue#61 FIX: use set_config for empty string
  -- MJV FIX #43: also had to reset search_path from source schema to empty.
  -- SET search_path = '';
  SELECT set_config('search_path', '', false)
  INTO v_dummy;

  cnt := 0;
  --FOR object IN
    -- SELECT table_name::text, view_definition
    -- FROM information_schema.views
    -- WHERE table_schema = quote_ident(source_schema)

  -- Issue#73 replace loop query to handle dependencies
  -- Issue#91 get view_owner
  FOR srctbl, aname, view_owner, object IN
    WITH RECURSIVE views AS (
       SELECT n.nspname as schemaname, v.relname as tablename, v.oid::regclass AS viewname,
              v.relkind = 'm' AS is_materialized, pg_catalog.pg_get_userbyid(v.relowner) as owner, 
              1 AS level
       FROM pg_depend AS d
          JOIN pg_rewrite AS r
             ON r.oid = d.objid
          JOIN pg_class AS v
             ON v.oid = r.ev_class
          JOIN pg_namespace n
             ON n.oid = v.relnamespace
       -- WHERE v.relkind IN ('v', 'm')
       WHERE v.relkind IN ('v')
         AND d.classid = 'pg_rewrite'::regclass
         AND d.refclassid = 'pg_class'::regclass
         AND d.deptype = 'n'
    UNION
       -- add the views that depend on these
       SELECT n.nspname as schemaname, v.relname as tablename, v.oid::regclass AS viewname,
              v.relkind = 'm', pg_catalog.pg_get_userbyid(v.relowner) as owner, 
              views.level + 1
       FROM views
          JOIN pg_depend AS d
             ON d.refobjid = views.viewname
          JOIN pg_rewrite AS r
             ON r.oid = d.objid
          JOIN pg_class AS v
             ON v.oid = r.ev_class
          JOIN pg_namespace n
             ON n.oid = v.relnamespace
       -- WHERE v.relkind IN ('v', 'm')
       WHERE v.relkind IN ('v')
         AND d.classid = 'pg_rewrite'::regclass
             AND d.refclassid = 'pg_class'::regclass
         AND d.deptype = 'n'
         AND v.oid <> views.viewname
    )
    SELECT tablename, viewname, owner, format('CREATE OR REPLACE%s VIEW %s AS%s',
                  CASE WHEN is_materialized
                       THEN ' MATERIALIZED'
                       ELSE ''
                  END,
                  viewname,
                  pg_get_viewdef(viewname))
    FROM views
    WHERE schemaname = quote_ident(source_schema)
    GROUP BY schemaname, tablename, viewname, owner, is_materialized
    ORDER BY max(level), schemaname, tablename
  LOOP
    cnt := cnt + 1;
    -- Issue#73 replace logic based on new loop sql
    buffer := quote_ident(dest_schema) || '.' || quote_ident(aname);
    -- MJV FIX: #43
    -- SELECT view_definition INTO v_def
    -- SELECT REPLACE(view_definition, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.') INTO v_def
    -- FROM information_schema.views
    -- WHERE table_schema = quote_ident(source_schema)
    --   AND table_name = quote_ident(object);
    SELECT REPLACE(object, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.') INTO v_def;
    -- NOTE: definition already includes the closing statement semicolon
    SELECT REPLACE(aname, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.') INTO buffer3;
    IF bDDLOnly THEN
      RAISE INFO '%', v_def;
      -- Issue#91 Fix
      -- issue#95 
      IF NOT bNoOwner THEN
        -- Fixed Issue#108: double-quote roles in case they have special characters
        -- RAISE INFO 'ALTER TABLE % OWNER TO %', buffer3, view_owner || ';';
        RAISE INFO 'ALTER TABLE % OWNER TO %', buffer3, '"' ||view_owner || '";';
      END IF;        
    ELSE
      -- EXECUTE 'CREATE OR REPLACE VIEW ' || buffer || ' AS ' || v_def;
      lastsql = v_def;
      EXECUTE v_def;
      lastsql = '';
      -- Issue#73: commented out comment logic for views since we do it elsewhere now.
      -- Issue#91 Fix
      -- issue#95 
      IF NOT bNoOwner THEN      
        -- Fixed Issue#108: double-quote roles in case they have special characters
        v_def = 'ALTER TABLE ' || buffer3 || ' OWNER TO ' || '"' || view_owner || '";';
        lastsql = v_def;
        EXECUTE v_def;
        lastsql = '';
      END IF;
    END IF;
  END LOOP;
  RAISE NOTICE '       VIEWS cloned: %', LPAD(cnt::text, 5, ' ');

  -- Create Materialized views
  action := 'Mat. Views';
  cnt := 0;
  -- Issue#91 get view_owner
  FOR object, view_owner, v_def IN
      SELECT matviewname::text, '"' || matviewowner::text || '"', replace(definition,';','') FROM pg_catalog.pg_matviews WHERE schemaname = quote_ident(source_schema)
  LOOP
      cnt := cnt + 1;
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on target schema and object
      buffer := quote_ident(dest_schema) || '.' || quote_ident(object);

      -- MJV FIX: #72 remove source schema in MV def
      SELECT REPLACE(v_def, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.') INTO buffer2;

      IF bData THEN
        -- issue#98 defer creation until after regular tables are populated. Also defer the ownership as well.
        -- EXECUTE 'CREATE MATERIALIZED VIEW ' || buffer || ' AS ' || buffer2 || ' WITH DATA;' ;
        buffer3 = 'CREATE MATERIALIZED VIEW ' || buffer || ' AS ' || buffer2 || ' WITH DATA;';
        mvarray := mvarray || buffer3;
        
        -- issue#95 
        IF NOT bNoOwner THEN      
          -- buffer3 = 'ALTER MATERIALIZED VIEW ' || buffer || ' OWNER TO ' || view_owner || ';' ;
          -- EXECUTE buffer3;
          -- Fixed Issue#108: double-quote roles in case they have special characters
          buffer3 = 'ALTER MATERIALIZED VIEW ' || buffer || ' OWNER TO ' || view_owner || ';' ;
          mvarray := mvarray || buffer3;
        END IF;
      ELSE
        IF bDDLOnly THEN
          RAISE INFO '%', 'CREATE MATERIALIZED VIEW ' || buffer || ' AS ' || buffer2 || ' WITH NO DATA;' ;
          -- Issue#91
          -- issue#95 
          IF NOT bNoOwner THEN      
            -- Fixed Issue#108: double-quote roles in case they have special characters
            RAISE INFO '%', 'ALTER MATERIALIZED VIEW ' || buffer || ' OWNER TO ' || view_owner || ';' ;
          END IF;
        ELSE
          EXECUTE 'CREATE MATERIALIZED VIEW ' || buffer || ' AS ' || buffer2 || ' WITH NO DATA;' ;
          -- Issue#91
          -- issue#95 
          IF NOT bNoOwner THEN      
            -- Fixed Issue#108: double-quote roles in case they have special characters
            buffer3 = 'ALTER MATERIALIZED VIEW ' || buffer || ' OWNER TO ' || view_owner || ';' ;
            lastsql = buffer3;
            EXECUTE buffer3;
            lastsql = '';
          END IF;
        END IF;
      END IF;
      SELECT coalesce(obj_description(oid), '') into adef from pg_class where relkind = 'm' and relname = object;
      IF adef <> '' THEN
        IF bDDLOnly THEN
          RAISE INFO '%', 'COMMENT ON MATERIALIZED VIEW ' || quote_ident(dest_schema) || '.' || object || ' IS ''' || adef || ''';';
        ELSE
          -- Issue#$98: also defer if copy rows is on since we defer MVIEWS in that case
          IF bData THEN
            buffer3 = 'COMMENT ON MATERIALIZED VIEW ' || quote_ident(dest_schema) || '.' || object || ' IS ''' || adef || ''';';
            mvarray = mvarray || buffer3;
          ELSE
            EXECUTE 'COMMENT ON MATERIALIZED VIEW ' || quote_ident(dest_schema) || '.' || object || ' IS ''' || adef || ''';';
          END IF;
          
        END IF;
      END IF;

      FOR aname, adef IN
        SELECT indexname, replace(indexdef, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.') as newdef FROM pg_indexes where schemaname = quote_ident(source_schema) and tablename = object order by indexname
      LOOP
        IF bDDLOnly THEN
          RAISE INFO '%', adef || ';';
        ELSE
          IF bData THEN
              -- #issue#116 defer materialized view index creations as well
              mvarray = mvarray || adef;  
          ELSE
              lastsql = adef; 
              EXECUTE adef || ';';
              lastsql = '';
          END IF;        
        END IF;        
      END LOOP;

  END LOOP;
  RAISE NOTICE '   MAT VIEWS cloned: %', LPAD(cnt::text, 5, ' ');

  -- Issue 90 Move create functions to before views
  
  
  -- Issue#111: forces us to defer triggers til after we populate the tables, just like we did with FKeys (Issue#78).
  -- MV: Create Triggers
    SELECT set_config('search_path', '', false) into v_dummy;

  -- MV: Create Rules
  -- Fixes Issue#59 Implement Rules
  action := 'Rules';
  cnt := 0;
  FOR arec IN
    SELECT regexp_replace(definition, E'[\\n\\r]+', ' ', 'g' ) as definition
    FROM pg_rules
    WHERE schemaname = quote_ident(source_schema)
  LOOP
    cnt := cnt + 1;
    buffer := REPLACE(arec.definition, quote_ident(source_schema) || '.', quote_ident(dest_schema) || '.');
    IF bDDLOnly THEN
      RAISE INFO '%', buffer;
    ELSE
      lastsql = buffer;
      EXECUTE buffer;
      lastsql = '';
    END IF;
  END LOOP;
  RAISE NOTICE '    RULES    cloned: %', LPAD(cnt::text, 5, ' ');


  -- MV: Create Policies
  -- Fixes Issue#66 Implement Security policies for RLS
  action := 'Policies';
  cnt := 0;
  -- #106 Handle 9.6 which doesn't have "permissive"
  IF sq_server_version_num > 90624 THEN
    FOR arec IN
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on policy, tablename
      -- Issue#113 FIX: quote_ident() the policy name and handle case where qual is null (INSERT policies)
      -- SELECT schemaname as schemaname, tablename as tablename, 'CREATE POLICY ' || quote_ident(policyname) || ' ON ' || quote_ident(dest_schema) || '.' || quote_ident(tablename) || ' AS ' || permissive || ' FOR ' || cmd || ' TO '
      -- ||  array_to_string(roles, ',', '*') || ' USING (' || regexp_replace(qual, E'[\\n\\r]+', ' ', 'g' ) || ')'
      -- || CASE WHEN with_check IS NOT NULL THEN ' WITH CHECK (' ELSE '' END || coalesce(with_check, '') || CASE WHEN with_check IS NOT NULL THEN ');' ELSE ';' END as definition
      -- FROM pg_policies WHERE schemaname = quote_ident(source_schema) ORDER BY policyname
      SELECT schemaname as schemaname, tablename as tablename, 'CREATE POLICY ' || quote_ident(policyname) || ' ON ' || quote_ident(dest_schema) || '.' || quote_ident(tablename) || ' AS ' || permissive || ' FOR ' || cmd || ' TO '
      ||  array_to_string(roles, ',', '*') || CASE WHEN qual is NULL THEN ' ' ELSE ' USING (' || regexp_replace(qual, E'[\\n\\r]+', ' ', 'g' )  || ')' END 
      || CASE WHEN with_check IS NOT NULL THEN ' WITH CHECK (' ELSE '' END || coalesce(with_check, '') || CASE WHEN with_check IS NOT NULL THEN ');' ELSE ';' END as definition
      FROM pg_policies WHERE schemaname = quote_ident(source_schema) ORDER BY policyname
    LOOP
      cnt := cnt + 1;
      IF bDDLOnly THEN
        RAISE INFO '%', arec.definition;
      ELSE
        IF bDebug THEN RAISE NOTICE 'DEBUG: policiesA - %', arec.definition; END IF;
        lastsql = arec.definition;
        EXECUTE arec.definition;
        lastsql = '';
      END IF;
    
      -- Issue#76: Enable row security if indicated
      SELECT c.relrowsecurity INTO abool FROM pg_class c, pg_namespace n where n.nspname = quote_ident(arec.schemaname) AND n.oid = c.relnamespace AND c.relname = quote_ident(arec.tablename) and c.relkind = 'r';
      IF abool THEN
        buffer = 'ALTER TABLE ' || dest_schema || '.' || arec.tablename || ' ENABLE ROW LEVEL SECURITY;';
        IF bDDLOnly THEN
          RAISE INFO '%', buffer;
        ELSE
          IF bDebug THEN RAISE NOTICE 'DEBUG: policiesB - %', arec.definition; END IF;
          lastsql = arec.definition;
          EXECUTE buffer;
          lastsql = '';
        END IF;
      END IF;
    END LOOP;
  ELSE
    -- handle 9.6 versions
    FOR arec IN
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on policy, tablename
      -- Issue#113 FIX: quote_ident() the policy name and handle case where qual is null (INSERT policies)
      -- SELECT schemaname as schemaname, tablename as tablename, 'CREATE POLICY ' || policyname || ' ON ' || quote_ident(dest_schema) || '.' || quote_ident(tablename) || ' FOR ' || cmd || ' TO '
      -- ||  array_to_string(roles, ',', '*') || ' USING (' || regexp_replace(qual, E'[\\n\\r]+', ' ', 'g' ) || ')'
      -- || CASE WHEN with_check IS NOT NULL THEN ' WITH CHECK (' ELSE '' END || coalesce(with_check, '') || CASE WHEN with_check IS NOT NULL THEN ');' ELSE ';' END as definition
      -- FROM pg_policies WHERE schemaname = quote_ident(source_schema) ORDER BY policyname
      SELECT schemaname as schemaname, tablename as tablename, 'CREATE POLICY ' || quote_ident(policyname) || ' ON ' || quote_ident(dest_schema) || '.' || quote_ident(tablename) || ' FOR ' || cmd || ' TO '
      ||  array_to_string(roles, ',', '*') || CASE WHEN qual is NULL THEN ' ' ELSE ' USING (' || regexp_replace(qual, E'[\\n\\r]+', ' ', 'g' )  || ')' END 
      || CASE WHEN with_check IS NOT NULL THEN ' WITH CHECK (' ELSE '' END || coalesce(with_check, '') || CASE WHEN with_check IS NOT NULL THEN ');' ELSE ';' END as definition
      FROM pg_policies WHERE schemaname = quote_ident(source_schema) ORDER BY policyname
    LOOP
      cnt := cnt + 1;
      IF bDDLOnly THEN
        RAISE INFO '%', arec.definition;
      ELSE
        lastsql = arec.definition;
        EXECUTE arec.definition;
        lastsql = '';
      END IF;
    
      -- Issue#76: Enable row security if indicated
      SELECT c.relrowsecurity INTO abool FROM pg_class c, pg_namespace n where n.nspname = quote_ident(arec.schemaname) AND n.oid = c.relnamespace AND c.relname = quote_ident(arec.tablename) and c.relkind = 'r';
      IF abool THEN
        buffer = 'ALTER TABLE ' || dest_schema || '.' || arec.tablename || ' ENABLE ROW LEVEL SECURITY;';
        IF bDDLOnly THEN
          RAISE INFO '%', buffer;
        ELSE
          lastsql = buffer;
          EXECUTE buffer;
          lastsql = '';
        END IF;
      END IF;
    END LOOP;  
  END IF;
  RAISE NOTICE '    POLICIES cloned: %', LPAD(cnt::text, 5, ' ');


  -- MJV Fixed #62 for comments (PASS 1)
  action := 'Comments1';
  cnt := 0;
  FOR qry IN
    -- Issue#74 Fix: Change schema from source to target. Also, do not include comments on foreign tables since we do not clone foreign tables at this time.
    SELECT 'COMMENT ON ' || CASE WHEN c.relkind in ('r','p') AND a.attname IS NULL THEN 'TABLE ' WHEN c.relkind in ('r','p') AND
    a.attname IS NOT NULL THEN 'COLUMN ' WHEN c.relkind = 'f' THEN 'FOREIGN TABLE ' WHEN c.relkind = 'm' THEN 'MATERIALIZED VIEW ' WHEN c.relkind = 'v' THEN 'VIEW '
    WHEN c.relkind = 'i' THEN 'INDEX ' WHEN c.relkind = 'S' THEN 'SEQUENCE ' ELSE 'XX' END || quote_ident(dest_schema) || '.' || CASE WHEN c.relkind in ('r','p') AND
    -- Issue#78: handle case-sensitive names with quote_ident()
    a.attname IS NOT NULL THEN quote_ident(c.relname) || '.' || a.attname ELSE quote_ident(c.relname) END ||
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    FROM pg_class c
    JOIN pg_namespace n ON (n.oid = c.relnamespace)
    LEFT JOIN pg_description d ON (c.oid = d.objoid)
    LEFT JOIN pg_attribute a ON (c.oid = a.attrelid
      AND a.attnum > 0 and a.attnum = d.objsubid)
    WHERE c.relkind <> 'f' AND d.description IS NOT NULL AND n.nspname = quote_ident(source_schema)
    ORDER BY ddl
  LOOP
    cnt := cnt + 1;
    
    -- BAD : "COMMENT ON SEQUENCE sample_clone2.CaseSensitive_ID_seq IS 'just a comment on CaseSensitive sequence';"
    -- GOOD: "COMMENT ON SEQUENCE "CaseSensitive_ID_seq" IS 'just a comment on CaseSensitive sequence';"
    
    -- Issue#98 For MVs we create comments when we create the MVs
    IF substring(qry,1,28) = 'COMMENT ON MATERIALIZED VIEW' THEN
      IF bDebug THEN RAISE NOTICE 'DEBUG: deferring comments on MVs'; END IF;
      cnt = cnt - 1;
      continue;
    END IF;
    
    IF bDDLOnly THEN
      RAISE INFO '%', qry;
    ELSE
      lastsql = qry;
      EXECUTE qry;
      lastsql = '';
    END IF;
  END LOOP;
  RAISE NOTICE ' COMMENTS(1) cloned: %', LPAD(cnt::text, 5, ' ');

  -- MJV Fixed #62 for comments (PASS 2)
  action := 'Comments2';
  cnt2 := 0;
  IF is_prokind THEN
  FOR qry IN
    -- Issue#74 Fix: Change schema from source to target.
    SELECT 'COMMENT ON SCHEMA ' || dest_schema ||
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    from pg_namespace n, pg_description d where d.objoid = n.oid and n.nspname = quote_ident(source_schema)
    UNION
    -- Issue#74 Fix: need to replace source schema inline
    -- SELECT 'COMMENT ON TYPE ' || pg_catalog.format_type(t.oid, NULL) || ' IS ''' || pg_catalog.obj_description(t.oid, 'pg_type') || ''';' as ddl
    SELECT 'COMMENT ON TYPE ' || REPLACE(pg_catalog.format_type(t.oid, NULL), quote_ident(source_schema), quote_ident(dest_schema)) || ' IS ''' || pg_catalog.obj_description(t.oid, 'pg_type') || ''';' as ddl
    FROM pg_catalog.pg_type t
    JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid))
      AND NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
      AND n.nspname = quote_ident(source_schema) COLLATE pg_catalog.default
      AND pg_catalog.obj_description(t.oid, 'pg_type') IS NOT NULL and t.typtype = 'c'
    UNION
    -- Issue#78: handle case-sensitive names with quote_ident()
    SELECT 'COMMENT ON COLLATION ' || quote_ident(dest_schema) || '.' || quote_ident(c.collname) || ' IS ''' || pg_catalog.obj_description(c.oid, 'pg_collation') || ''';' as ddl
    FROM pg_catalog.pg_collation c, pg_catalog.pg_namespace n
    WHERE n.oid = c.collnamespace AND c.collencoding IN (-1, pg_catalog.pg_char_to_encoding(pg_catalog.getdatabaseencoding()))
      AND n.nspname = quote_ident(source_schema) COLLATE pg_catalog.default AND pg_catalog.obj_description(c.oid, 'pg_collation') IS NOT NULL
    UNION
    SELECT 'COMMENT ON ' || CASE WHEN p.prokind = 'f' THEN 'FUNCTION ' WHEN p.prokind = 'p' THEN 'PROCEDURE ' WHEN p.prokind = 'a' THEN 'AGGREGATE ' END ||
    dest_schema || '.' || p.proname || ' (' || oidvectortypes(p.proargtypes) || ')'
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    FROM pg_catalog.pg_namespace n
    JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid
    JOIN pg_description d ON (d.objoid = p.oid)
    WHERE n.nspname = quote_ident(source_schema)
    UNION
    SELECT 'COMMENT ON POLICY ' || p1.policyname || ' ON ' || dest_schema || '.' || p1.tablename ||
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    FROM pg_policies p1, pg_policy p2, pg_class c, pg_namespace n, pg_description d
    WHERE p1.schemaname = n.nspname AND p1.tablename = c.relname AND n.oid = c.relnamespace
      AND c.relkind in ('r','p') AND p1.policyname = p2.polname AND d.objoid = p2.oid AND p1.schemaname = quote_ident(source_schema)
    UNION
    SELECT 'COMMENT ON DOMAIN ' || dest_schema || '.' || t.typname ||
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    FROM pg_catalog.pg_type t
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    JOIN pg_catalog.pg_description d ON d.classoid = t.tableoid AND d.objoid = t.oid AND d.objsubid = 0
    WHERE t.typtype = 'd' AND n.nspname = quote_ident(source_schema) COLLATE pg_catalog.default
    ORDER BY 1
  LOOP
    cnt2 := cnt2 + 1;
    IF bDDLOnly THEN
      RAISE INFO '%', qry;
    ELSE
      lastsql = qry;
      EXECUTE qry;
      lastsql = '';
    END IF;
  END LOOP;
  ELSE -- must be v 10 or less
  FOR qry IN
    -- Issue#74 Fix: Change schema from source to target.
    SELECT 'COMMENT ON SCHEMA ' || dest_schema ||
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    from pg_namespace n, pg_description d where d.objoid = n.oid and n.nspname = quote_ident(source_schema)
    UNION
    -- Issue#74 Fix: need to replace source schema inline
    -- SELECT 'COMMENT ON TYPE ' || pg_catalog.format_type(t.oid, NULL) || ' IS ''' || pg_catalog.obj_description(t.oid, 'pg_type') || ''';' as ddl
    SELECT 'COMMENT ON TYPE ' || REPLACE(pg_catalog.format_type(t.oid, NULL), quote_ident(source_schema), quote_ident(dest_schema)) || ' IS ''' || pg_catalog.obj_description(t.oid, 'pg_type') || ''';' as ddl
    FROM pg_catalog.pg_type t
    JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c'
                              FROM pg_catalog.pg_class c
                              WHERE c.oid = t.typrelid))
      AND NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el
                     WHERE el.oid = t.typelem AND el.typarray = t.oid)
      AND n.nspname = quote_ident(source_schema) COLLATE pg_catalog.default
      AND pg_catalog.obj_description(t.oid, 'pg_type') IS NOT NULL and t.typtype = 'c'
    UNION
    -- FIX Isse#87 by adding double quotes around collation name
    SELECT 'COMMENT ON COLLATION ' || dest_schema || '."' || c.collname || '" IS ''' || pg_catalog.obj_description(c.oid, 'pg_collation') || ''';' as ddl
    FROM pg_catalog.pg_collation c, pg_catalog.pg_namespace n
    WHERE n.oid = c.collnamespace AND c.collencoding IN (-1, pg_catalog.pg_char_to_encoding(pg_catalog.getdatabaseencoding()))
      AND n.nspname = quote_ident(source_schema) COLLATE pg_catalog.default AND pg_catalog.obj_description(c.oid, 'pg_collation') IS NOT NULL
    UNION
    SELECT 'COMMENT ON ' || CASE WHEN proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END ||
    dest_schema || '.' || p.proname || ' (' || oidvectortypes(p.proargtypes) || ')'
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    FROM pg_catalog.pg_namespace n
    JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid
    JOIN pg_description d ON (d.objoid = p.oid)
    WHERE n.nspname = quote_ident(source_schema)
    UNION
    SELECT 'COMMENT ON POLICY ' || p1.policyname || ' ON ' || dest_schema || '.' || p1.tablename ||
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    FROM pg_policies p1, pg_policy p2, pg_class c, pg_namespace n, pg_description d
    WHERE p1.schemaname = n.nspname AND p1.tablename = c.relname AND n.oid = c.relnamespace
      AND c.relkind in ('r','p') AND p1.policyname = p2.polname AND d.objoid = p2.oid AND p1.schemaname = quote_ident(source_schema)
    UNION
    SELECT 'COMMENT ON DOMAIN ' || dest_schema || '.' || t.typname ||
    -- Issue#74 Fix
    -- ' IS ''' || d.description || ''';' as ddl
    ' IS '   || quote_literal(d.description) || ';' as ddl
    FROM pg_catalog.pg_type t
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    JOIN pg_catalog.pg_description d ON d.classoid = t.tableoid AND d.objoid = t.oid AND d.objsubid = 0
    WHERE t.typtype = 'd' AND n.nspname = quote_ident(source_schema) COLLATE pg_catalog.default
    ORDER BY 1
  LOOP
    cnt2 := cnt2 + 1;
    IF bDDLOnly THEN
      RAISE INFO '%', qry;
    ELSE
      lastsql = qry;
      EXECUTE qry;
      lastsql = '';
    END IF;
  END LOOP;
  END IF;
  RAISE NOTICE ' COMMENTS(2) cloned: %', LPAD(cnt2::text, 5, ' ');


  -- Issue#95 bypass if No ACL specified.
  IF NOT bNoACL THEN
    -- ---------------------
    -- MV: Permissions: Defaults
    -- ---------------------
    EXECUTE 'SET search_path = ' || quote_ident(source_schema) ;
    action := 'PRIVS: Defaults';
    cnt := 0;
    FOR arec IN
      SELECT pg_catalog.pg_get_userbyid(d.defaclrole) AS "owner", n.nspname AS schema,
      CASE d.defaclobjtype WHEN 'r' THEN 'table' WHEN 'S' THEN 'sequence' WHEN 'f' THEN 'function' WHEN 'T' THEN 'type' WHEN 'n' THEN 'schema' END AS atype,
      d.defaclacl as defaclacl, pg_catalog.array_to_string(d.defaclacl, ',') as defaclstr
      FROM pg_catalog.pg_default_acl d LEFT JOIN pg_catalog.pg_namespace n ON (n.oid = d.defaclnamespace)
      WHERE n.nspname IS NOT NULL AND n.nspname = quote_ident(source_schema)
      ORDER BY 3, 2, 1
    LOOP
      BEGIN
        -- RAISE NOTICE ' owner=%  type=%  defaclacl=%  defaclstr=%', arec.owner, arec.atype, arec.defaclacl, arec.defaclstr;

        FOREACH aclstr IN ARRAY arec.defaclacl
        LOOP
            cnt := cnt + 1;
            -- RAISE NOTICE ' aclstr=%', aclstr;
            -- break up into grantor, grantee, and privs, mydb_update=rwU/mydb_owner
            SELECT split_part(aclstr, '=',1) INTO grantee;
            SELECT split_part(aclstr, '=',2) INTO grantor;
            SELECT split_part(grantor, '/',1) INTO privs;
            SELECT split_part(grantor, '/',2) INTO grantor;
            -- RAISE NOTICE ' grantor=%  grantee=%  privs=%', grantor, grantee, privs;

            IF arec.atype = 'function' THEN
              -- Just having execute is enough to grant all apparently.
              buffer := 'ALTER DEFAULT PRIVILEGES FOR ROLE ' || grantor || ' IN SCHEMA ' || quote_ident(dest_schema) || ' GRANT ALL ON FUNCTIONS TO "' || grantee || '";';
            
              -- Issue#92 Fix
              -- set role = cm_stage_ro_grp;
              -- ALTER DEFAULT PRIVILEGES FOR ROLE cm_stage_ro_grp IN SCHEMA cm_stage GRANT REFERENCES, TRIGGER ON TABLES TO cm_stage_ro_grp;
              IF grantor = grantee THEN
                  -- append set role to statement
                  buffer = 'SET ROLE = ' || grantor || '; ' || buffer;
              END IF;
            
              IF bDDLOnly THEN
                RAISE INFO '%', buffer;
              ELSE
                lastsql = buffer;
                EXECUTE buffer;
                lastsql = '';
              END IF;
              -- Issue#92 Fix:
              EXECUTE 'SET ROLE = ' || calleruser;
            
            ELSIF arec.atype = 'sequence' THEN
              IF POSITION('r' IN privs) > 0 AND POSITION('w' IN privs) > 0 AND POSITION('U' IN privs) > 0 THEN
                -- arU is enough for all privs
                buffer := 'ALTER DEFAULT PRIVILEGES FOR ROLE ' || grantor || ' IN SCHEMA ' || quote_ident(dest_schema) || ' GRANT ALL ON SEQUENCES TO "' || grantee || '";';
              
                -- Issue#92 Fix
                IF grantor = grantee THEN
                    -- append set role to statement
                    buffer = 'SET ROLE = ' || grantor || '; ' || buffer;
                END IF;

                IF bDDLOnly THEN
                  RAISE INFO '%', buffer;
                ELSE
                  lastsql = buffer;
                  EXECUTE buffer;
                  lastsql = '';
                END IF;
                -- Issue#92 Fix:
                EXECUTE 'SET ROLE = ' || calleruser;

              ELSE
                -- have to specify each priv individually
                buffer2 := '';
                IF POSITION('r' IN privs) > 0 THEN
                      buffer2 := 'SELECT';
                END IF;
                IF POSITION('w' IN privs) > 0 THEN
                  IF buffer2 = '' THEN
                    buffer2 := 'UPDATE';
                  ELSE
                    buffer2 := buffer2 || ', UPDATE';
                  END IF;
                END IF;
                IF POSITION('U' IN privs) > 0 THEN
                      IF buffer2 = '' THEN
                    buffer2 := 'USAGE';
                  ELSE
                    buffer2 := buffer2 || ', USAGE';
                  END IF;
                END IF;
                buffer := 'ALTER DEFAULT PRIVILEGES FOR ROLE ' || grantor || ' IN SCHEMA ' || quote_ident(dest_schema) || ' GRANT ' || buffer2 || ' ON SEQUENCES TO "' || grantee || '";';

                -- Issue#92 Fix
                IF grantor = grantee THEN
                    -- append set role to statement
                    buffer = 'SET ROLE = ' || grantor || '; ' || buffer;
                END IF;
              
                IF bDDLOnly THEN
                  RAISE INFO '%', buffer;
                ELSE
                  lastsql = buffer;
                  EXECUTE buffer;
                  lastsql = '';
                END IF;
                select current_user into buffer;
                -- Issue#92 Fix:
                EXECUTE 'SET ROLE = ' || calleruser;
              END IF;

            ELSIF arec.atype = 'table' THEN
              -- do each priv individually, jeeeesh!
              buffer2 := '';
              IF POSITION('a' IN privs) > 0 THEN
                buffer2 := 'INSERT';
              END IF;
              IF POSITION('r' IN privs) > 0 THEN
                IF buffer2 = '' THEN
                  buffer2 := 'SELECT';
                ELSE
                  buffer2 := buffer2 || ', SELECT';
                END IF;
              END IF;
              IF POSITION('w' IN privs) > 0 THEN
                IF buffer2 = '' THEN
                  buffer2 := 'UPDATE';
                ELSE
                  buffer2 := buffer2 || ', UPDATE';
                END IF;
              END IF;
              IF POSITION('d' IN privs) > 0 THEN
                IF buffer2 = '' THEN
                  buffer2 := 'DELETE';
                ELSE
                  buffer2 := buffer2 || ', DELETE';
                END IF;
              END IF;
              IF POSITION('t' IN privs) > 0 THEN
                IF buffer2 = '' THEN
                  buffer2 := 'TRIGGER';
                ELSE
                  buffer2 := buffer2 || ', TRIGGER';
                END IF;
              END IF;
              IF POSITION('T' IN privs) > 0 THEN
                IF buffer2 = '' THEN
                  buffer2 := 'TRUNCATE';
                ELSE
                  buffer2 := buffer2 || ', TRUNCATE';
                END IF;
              END IF;
              buffer := 'ALTER DEFAULT PRIVILEGES FOR ROLE ' || grantor || ' IN SCHEMA ' || quote_ident(dest_schema) || ' GRANT ' || buffer2 || ' ON TABLES TO "' || grantee || '";';
            
              -- Issue#92 Fix
              IF grantor = grantee THEN
                  -- append set role to statement
                  buffer = 'SET ROLE = ' || grantor || '; ' || buffer;
              END IF;
            
              IF bDDLOnly THEN
                RAISE INFO '%', buffer;
              ELSE
                lastsql = buffer;
                EXECUTE buffer;
                lastsql = '';
              END IF;
              select current_user into buffer;
              -- Issue#92 Fix:
              EXECUTE 'SET ROLE = ' || calleruser;

            ELSIF arec.atype = 'type' THEN
              IF POSITION('r' IN privs) > 0 AND POSITION('w' IN privs) > 0 AND POSITION('U' IN privs) > 0 THEN
                -- arU is enough for all privs
                buffer := 'ALTER DEFAULT PRIVILEGES FOR ROLE ' || grantor || ' IN SCHEMA ' || quote_ident(dest_schema) || ' GRANT ALL ON TYPES TO "' || grantee || '";';
                
                -- Issue#92 Fix
                IF grantor = grantee THEN
                    -- append set role to statement
                    buffer = 'SET ROLE = ' || grantor || '; ' || buffer;
                END IF;
              
                IF bDDLOnly THEN
                  RAISE INFO '%', buffer;
                ELSE
                  lastsql = buffer;
                  EXECUTE buffer;
                  lastsql = '';
                END IF;
                -- Issue#92 Fix:
                EXECUTE 'SET ROLE = ' || calleruser;
              
              ELSIF POSITION('U' IN privs) THEN
                buffer := 'ALTER DEFAULT PRIVILEGES FOR ROLE ' || grantor || ' IN SCHEMA ' || quote_ident(dest_schema) || ' GRANT USAGE ON TYPES TO "' || grantee || '";';
              
                -- Issue#92 Fix
                IF grantor = grantee THEN
                    -- append set role to statement
                    buffer = 'SET ROLE = ' || grantor || '; ' || buffer;
                END IF;
              
                IF bDDLOnly THEN
                  RAISE INFO '%', buffer;
                ELSE
                  lastsql = buffer;
                  EXECUTE buffer;
                  lastsql = '';
                END IF;
                -- Issue#92 Fix:
                EXECUTE 'SET ROLE = ' || calleruser;
              
              ELSE
                RAISE WARNING 'Unhandled TYPE Privs:: type=%  privs=%  owner=%   defaclacl=%  defaclstr=%  grantor=%  grantee=% ', arec.atype, privs, arec.owner, arec.defaclacl, arec.defaclstr, grantor, grantee;
            END IF;
          ELSE
            RAISE WARNING 'Unhandled Privs:: type=%  privs=%  owner=%   defaclacl=%  defaclstr=%  grantor=%  grantee=% ', arec.atype, privs, arec.owner, arec.defaclacl, arec.defaclstr, grantor, grantee;
          END IF;
        END LOOP;
      END;
    END LOOP;
  
    RAISE NOTICE '  DFLT PRIVS cloned: %', LPAD(cnt::text, 5, ' ');    
  END IF; -- NO ACL BRANCH

  -- Issue#95 bypass if No ACL specified
  IF NOT bNoACL THEN
    -- MV: PRIVS: schema
    -- crunchy data extension, check_access
    -- SELECT role_path, base_role, as_role, objtype, schemaname, objname, array_to_string(array_agg(privname),',') as privs  FROM all_access()
    -- WHERE base_role != CURRENT_USER and objtype = 'schema' and schemaname = 'public' group by 1,2,3,4,5,6;

    action := 'PRIVS: Schema';
    cnt := 0;
    FOR arec IN
      SELECT 'GRANT ' || p.perm::perm_type || ' ON SCHEMA ' || quote_ident(dest_schema) || ' TO "' || r.rolname || '";' as schema_ddl
      FROM pg_catalog.pg_namespace AS n
      CROSS JOIN pg_catalog.pg_roles AS r
      CROSS JOIN (VALUES ('USAGE'), ('CREATE')) AS p(perm)
      WHERE n.nspname = quote_ident(source_schema) AND NOT r.rolsuper AND has_schema_privilege(r.oid, n.oid, p.perm)
      ORDER BY r.rolname, p.perm::perm_type
    LOOP
      BEGIN
        cnt := cnt + 1;
        IF bDDLOnly THEN
          RAISE INFO '%', arec.schema_ddl;
        ELSE
          lastsql = arec.schema_ddl;
          EXECUTE arec.schema_ddl;
          lastsql = '';
        END IF;
  
      END;
    END LOOP;
    RAISE NOTICE 'SCHEMA PRIVS cloned: %', LPAD(cnt::text, 5, ' ');
  END IF; -- NO ACL BRANCH

  -- Issue#95 bypass if No ACL specified
  IF NOT bNoACL THEN
    -- MV: PRIVS: sequences
    action := 'PRIVS: Sequences';
    cnt := 0;
    FOR arec IN
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on t.relname
      SELECT 'GRANT ' || p.perm::perm_type || ' ON ' || quote_ident(dest_schema) || '.' || quote_ident(t.relname::text) || ' TO "' || r.rolname || '";' as seq_ddl
      FROM pg_catalog.pg_class AS t
      CROSS JOIN pg_catalog.pg_roles AS r
      CROSS JOIN (VALUES ('SELECT'), ('USAGE'), ('UPDATE')) AS p(perm)
      WHERE t.relnamespace::regnamespace::name = quote_ident(source_schema) AND t.relkind = 'S'  AND NOT r.rolsuper AND has_sequence_privilege(r.oid, t.oid, p.perm)
    LOOP
      BEGIN
        cnt := cnt + 1;
        -- IF bDebug THEN RAISE NOTICE 'DEBUG: ddl=%', arec.seq_ddl; END IF;
        IF bDDLOnly THEN
          RAISE INFO '%', arec.seq_ddl;
        ELSE
          lastsql = arec.seq_ddl;
          EXECUTE arec.seq_ddl;
          lastsql = '';
        END IF;
      END;
    END LOOP;
    RAISE NOTICE '  SEQ. PRIVS cloned: %', LPAD(cnt::text, 5, ' ');
  END IF; -- NO ACL BRANCH    

  -- Issue#95 bypass if No ACL specified
  IF NOT bNoACL THEN
    -- MV: PRIVS: functions
    action := 'PRIVS: Functions/Procedures';
    cnt := 0;

    -- Issue#61 FIX: use set_config for empty string
    -- SET search_path = '';
    SELECT set_config('search_path', '', false) into v_dummy;

    -- RAISE NOTICE ' source_schema=%  dest_schema=%',source_schema, dest_schema;
    FOR arec IN
      -- 2021-03-05 MJV FIX: issue#35: caused exception in some functions with parameters and gave privileges to other users that should not have gotten them.
      -- SELECT 'GRANT EXECUTE ON FUNCTION ' || quote_ident(dest_schema) || '.' || replace(regexp_replace(f.oid::regprocedure::text, '^((("[^"]*")|([^"][^.]*))\.)?', ''), source_schema, dest_schema) || ' TO "' || r.rolname || '";' as func_ddl
      -- FROM pg_catalog.pg_proc f CROSS JOIN pg_catalog.pg_roles AS r WHERE f.pronamespace::regnamespace::name = quote_ident(source_schema) AND NOT r.rolsuper AND has_function_privilege(r.oid, f.oid, 'EXECUTE')
      -- order by regexp_replace(f.oid::regprocedure::text, '^((("[^"]*")|([^"][^.]*))\.)?', '')

      -- 2021-03-05 MJV FIX: issue#37: defaults cause problems, use system function that returns args WITHOUT DEFAULTS
      -- COALESCE(r.routine_type, 'FUNCTION'): for aggregate functions, information_schema.routines contains NULL as routine_type value.
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on rp.routine_name
      SELECT 'GRANT ' || rp.privilege_type || ' ON ' || COALESCE(r.routine_type, 'FUNCTION') || ' ' || quote_ident(dest_schema) || '.' || quote_ident(rp.routine_name) || ' (' || pg_get_function_identity_arguments(p.oid) || ') TO ' || string_agg(distinct rp.grantee, ',') || ';' as func_dcl
      FROM information_schema.routine_privileges rp, information_schema.routines r, pg_proc p, pg_namespace n
      WHERE rp.routine_schema = quote_ident(source_schema)
        AND rp.is_grantable = 'YES'
        AND rp.routine_schema = r.routine_schema
        AND rp.routine_name = r.routine_name
        AND rp.routine_schema = n.nspname
        AND n.oid = p.pronamespace
        AND p.proname = r.routine_name
      GROUP BY rp.privilege_type, r.routine_type, rp.routine_name, pg_get_function_identity_arguments(p.oid)
    LOOP
      BEGIN
        cnt := cnt + 1;
        IF bDDLOnly THEN
          RAISE INFO '%', arec.func_dcl;
        ELSE
          lastsql = arec.func_dcl;
          EXECUTE arec.func_dcl;
          lastsql = '';
        END IF;
      END;
    END LOOP;
    EXECUTE 'SET search_path = ' || quote_ident(source_schema) ;
    RAISE NOTICE '  FUNC PRIVS cloned: %', LPAD(cnt::text, 5, ' ');
  END IF; -- NO ACL BRANCH

  -- Issue#95 bypass if No ACL specified
  IF NOT bNoACL THEN
    -- MV: PRIVS: tables
    action := 'PRIVS: Tables';
    -- regular, partitioned, and foreign tables plus view and materialized view permissions. Ignored for now: implement foreign table defs.
    cnt := 0;
    FOR arec IN
      -- 2021-03-05  MJV FIX: Fixed Issue#36 for tables
      -- Issue#78 FIX: handle case-sensitive names with quote_ident() on t.relname      
      -- 2024-01-24  MJV FIX: Issue#117    
      SELECT c.relkind, 'GRANT ' || tb.privilege_type || CASE WHEN c.relkind in ('r', 'p') THEN ' ON TABLE ' WHEN c.relkind in ('v', 'm')  THEN ' ON ' END ||
      quote_ident(dest_schema) || '.' || quote_ident(tb.table_name) || ' TO ' || string_agg(tb.grantee, ',') || ';' as tbl_dcl
      FROM information_schema.table_privileges tb, pg_class c, pg_namespace n
      WHERE tb.table_schema = quote_ident(source_schema) AND tb.table_name = c.relname AND c.relkind in ('r', 'p', 'v', 'm')
        AND c.relnamespace = n.oid AND n.nspname = quote_ident(source_schema)
        GROUP BY c.relkind, tb.privilege_type, tb.table_schema, tb.table_name 
        ORDER BY tb.table_name, tb.privilege_type
    LOOP
      BEGIN
        cnt := cnt + 1;
        -- IF bDebug THEN RAISE NOTICE 'DEBUG: ddl=%', arec.tbl_dcl; END IF;
        -- Issue#46. Fixed reference to invalid record name (tbl_ddl --> tbl_dcl).
        IF arec.relkind = 'f' THEN
          RAISE WARNING 'Foreign tables are not currently implemented, so skipping privs for them. ddl=%', arec.tbl_dcl;
        ELSE
            IF bDDLOnly THEN
                RAISE INFO '%', arec.tbl_dcl;
            ELSE
                lastsql = arec.tbl_dcl;
                EXECUTE arec.tbl_dcl;
                lastsql = '';
              END IF;
      END IF;
      END;
    END LOOP;
    RAISE NOTICE ' TABLE PRIVS cloned: %', LPAD(cnt::text, 5, ' ');
  END IF; -- NO ACL BRANCH

  -- LOOP for regular tables and populate them if specified
  -- Issue#75 moved from big table loop above to here.
  IF bData THEN
    r = clock_timestamp();
    -- IF bVerbose THEN RAISE NOTICE 'START: copy rows %',clock_timestamp() - t; END IF;  
    IF bVerbose THEN RAISE NOTICE 'Copying rows...'; END IF;  

    EXECUTE 'SET search_path = ' || quote_ident(dest_schema) ;
    action := 'Copy Rows';
    FOREACH tblelement IN ARRAY tblarray
    LOOP 
       s = clock_timestamp();
       IF bDebug THEN RAISE NOTICE 'DEBUG1: no UDTs %', tblelement; END IF;
       lastsql = tblelement;
       EXECUTE tblelement;       
       lastsql = '';
       GET DIAGNOSTICS cnt = ROW_COUNT;  
       buffer = substring(tblelement, 13);
       SELECT POSITION(' OVERRIDING SYSTEM VALUE SELECT ' IN buffer) INTO cnt2; 
       IF cnt2 = 0 THEN
           SELECT POSITION(' SELECT ' IN buffer) INTO cnt2;
           buffer = substring(buffer,1, cnt2);       
       ELSE
           buffer = substring(buffer,1, cnt2);       
       END IF;
       SELECT RPAD(buffer, 35, ' ') INTO buffer;
       cnt2 := cast(extract(epoch from (clock_timestamp() - s)) as numeric(18,3));
       IF bVerbose THEN RAISE NOTICE 'Populated cloned table, %   Rows Copied: %    seconds: %', buffer, LPAD(cnt::text, 10, ' '), LPAD(cnt2::text, 5, ' '); END IF;
       tblscopied := tblscopied + 1;
    END LOOP;
    
    -- Issue#79 implementation
    -- Do same for tables with user-defined elements using copy to file method
    FOREACH tblelement IN ARRAY tblarray2
    LOOP 
       s = clock_timestamp();
       IF bDebug THEN RAISE NOTICE 'DEBUG2: UDTs %', tblelement; END IF;
       lastsql = tblelement;
       EXECUTE tblelement;       
       lastsql = '';
       GET DIAGNOSTICS cnt = ROW_COUNT;  
       
       -- STATEMENT LOOKS LIKE THIS:
       -- INSERT INTO sample11.warehouses SELECT * FROM sample.warehouses;
       -- INSERT INTO sample11.person OVERRIDING SYSTEM VALUE SELECT * FROM sample.person;  
       -- COPY sample.address TO '/tmp/cloneschema.tmp' WITH DELIMITER AS ',';\
       buffer = TRIM(tblelement::text);
       -- RAISE NOTICE 'element=%', buffer;
       cnt1 = POSITION('INSERT INTO' IN buffer);
       cnt2 = POSITION('COPY ' IN buffer);
       IF cnt1 > 0 THEN
           buffer = substring(buffer, 12);
       ELSIF cnt2 > 0 THEN
           buffer = substring(buffer, 5);
       ELSE
           RAISE EXCEPTION 'Programming Error for parsing tblarray2.';
       END IF;

       -- RAISE NOTICE 'buffer1=%', buffer;
       cnt1 = POSITION(' OVERRIDING ' IN buffer);
       cnt2 = POSITION('SELECT * FROM ' IN buffer);
       cnt3 = POSITION(' FROM ' IN buffer);
       cnt4 = POSITION(' TO ' IN buffer);
       IF cnt1 > 0 THEN
           buffer = substring(buffer, 1, cnt1-2);
       ELSIF cnt2 > 0 THEN
           buffer = substring(buffer, 1, cnt2-2);
       ELSIF cnt3 > 0 THEN
           buffer = substring(buffer, 1, cnt3-1);           
       ELSIF cnt4 > 0 THEN
           -- skip the COPY TO statements
           continue;
       ELSE
           RAISE EXCEPTION 'Programming Error for parsing tblarray2.';
       END IF;
       -- RAISE NOTICE 'buffer2=%', buffer;
       
       SELECT RPAD(buffer, 35, ' ') INTO buffer;
       -- RAISE NOTICE 'buffer3=%', buffer;
       cnt2 := cast(extract(epoch from (clock_timestamp() - s)) as numeric(18,3));
       IF bVerbose THEN RAISE NOTICE 'Populated cloned table, %   Rows Copied: %    seconds: %', buffer, LPAD(cnt::text, 10, ' '), LPAD(cnt2::text, 5, ' '); END IF;
       tblscopied := tblscopied + 1;
    END LOOP;    
    
    -- Issue#101 
    -- Do same for tables with user-defined elements using direct method with text cast
    FOREACH tblelement IN ARRAY tblarray3
    LOOP 
       s = clock_timestamp();
       IF bDebug THEN RAISE NOTICE 'DEBUG3: UDTs %', tblelement; END IF;
       lastsql = tblelement;
       EXECUTE tblelement;       
       lastsql = '';
       GET DIAGNOSTICS cnt = ROW_COUNT;  
       cnt2 = POSITION(' (' IN tblelement::text);
       cnt3 = POSITION('INSERT INTO ' IN tblelement::text);
       IF cnt3 > 0 THEN
           -- INSERT INTO sample7.citextusers           
           tblname = substring(tblelement, 12);
           tblname = Trim(substring(tblname, 1, cnt2 - 12));           
       ELSEIF cnt2 > 0 THEN
           tblname = substring(tblelement, 1, cnt2);
       ELSE
           -- program error
           RAISE EXCEPTION 'Program error: unable to parse tblarray3 for documenting row copy.';
       END IF;           
       SELECT RPAD(tblname, 35, ' ') INTO buffer;
       cnt2 := cast(extract(epoch from (clock_timestamp() - s)) as numeric(18,3));
       IF bVerbose THEN RAISE NOTICE 'Populated cloned table, %   Rows Copied: %    seconds: %', buffer, LPAD(cnt::text, 10, ' '), LPAD(cnt2::text, 5, ' '); END IF;
       tblscopied := tblscopied + 1;
    END LOOP;    
    
    -- Issue#98 MVs deferred until now
    FOREACH tblelement IN ARRAY mvarray
    LOOP 
       s = clock_timestamp();
       lastsql = tblelement;
       EXECUTE tblelement;       
       lastsql = '';
       -- get diagnostics for MV creates or refreshes does not work, always returns 1
       GET DIAGNOSTICS cnt = ROW_COUNT;  
       buffer = substring(tblelement, 25);
       cnt2 = POSITION(' AS ' IN buffer);
       IF cnt2 > 0 THEN
         buffer = Trim(substring(buffer, 1, cnt2));
         SELECT RPAD(buffer, 36, ' ') INTO buffer;
         cnt2 := cast(extract(epoch from (clock_timestamp() - s)) as numeric(18,3));
         IF bVerbose THEN RAISE NOTICE 'Populated Mat. View,    %  Rows Inserted:        ?    seconds: %', buffer, LPAD(cnt2::text, 5, ' '); END IF;
         mvscopied := mvscopied + 1;
       END IF;
    END LOOP;    
    
    cnt := cast(extract(epoch from (clock_timestamp() - r)) as numeric(18,3));
    IF bVerbose THEN RAISE NOTICE 'Copy rows duration: % seconds',cnt; END IF;  
  END IF;
  RAISE NOTICE '      TABLES copied: %', LPAD(tblscopied::text, 5, ' ');
  RAISE NOTICE ' MATVIEWS refreshed: %', LPAD(mvscopied::text, 5, ' ');

  -- Issue#120: deferred sequence owner definitions until now
  FOREACH tblelement IN ARRAY tblarray4
  LOOP 
     s = clock_timestamp();
     IF bDebug THEN RAISE NOTICE 'DEBUG: %', tblelement; END IF;
     EXECUTE tblelement;       
  END LOOP;    
  
  -- Issue#78 forces us to defer FKeys until the end since we previously did row copies before FKeys
  --  add FK constraint
  action := 'FK Constraints';
  cnt := 0;

  -- Issue#61 FIX: use set_config for empty string
  -- SET search_path = '';
  SELECT set_config('search_path', '', false) into v_dummy;

  FOR qry IN
    SELECT 'ALTER TABLE ' || quote_ident(dest_schema) || '.' || quote_ident(rn.relname)
                          || ' ADD CONSTRAINT ' || quote_ident(ct.conname) || ' ' || REPLACE(pg_get_constraintdef(ct.oid), 'REFERENCES ' || quote_ident(source_schema) || '.', 'REFERENCES ' 
                          || quote_ident(dest_schema) || '.') || ';'
    FROM pg_constraint ct
    JOIN pg_class rn ON rn.oid = ct.conrelid
    -- Issue#103 needed to addd this left join
    LEFT JOIN pg_inherits i ON (rn.oid = i.inhrelid)
    WHERE connamespace = src_oid
        AND rn.relkind = 'r'
        AND ct.contype = 'f'
        -- Issue#103 fix: needed to also add this null check
        AND i.inhrelid is null
  LOOP
    cnt := cnt + 1;
    IF bDDLOnly THEN
      RAISE INFO '%', qry;
    ELSE
      IF bDebug THEN RAISE NOTICE 'DEBUG: adding FKEY constraint: %', qry; END IF;
      lastsql = qry;
      EXECUTE qry;
      lastsql = '';
    END IF;
  END LOOP;
  EXECUTE 'SET search_path = ' || quote_ident(source_schema) ;
  RAISE NOTICE '       FKEYS cloned: %', LPAD(cnt::text, 5, ' ');

  -- Issue#111: forces us to defer triggers til after we populate the tables, just like we did with FKeys (Issue#78).
  SELECT set_config('search_path', '', false) into v_dummy;

  action := 'Triggers';
  cnt := 0;
  FOR arec IN
    -- 2021-03-09 MJV FIX: #40 fixed sql to get the def using pg_get_triggerdef() sql
    SELECT n.nspname, c.relname, t.tgname, p.proname, REPLACE(pg_get_triggerdef(t.oid), quote_ident(source_schema), quote_ident(dest_schema)) || ';' AS trig_ddl
    FROM pg_trigger t, pg_class c, pg_namespace n, pg_proc p
    WHERE n.nspname = quote_ident(source_schema)
      AND n.oid = c.relnamespace
      AND c.relkind in ('r','p')
      AND n.oid = p.pronamespace
      AND c.oid = t.tgrelid
      AND p.oid = t.tgfoid
      ORDER BY c.relname, t.tgname
  LOOP
    BEGIN
      cnt := cnt + 1;
      IF bDDLOnly THEN
        RAISE INFO '%', arec.trig_ddl;
      ELSE
        lastsql = arec.trig_ddl;
        EXECUTE arec.trig_ddl;
        lastsql = '';
      END IF;

    END;
  END LOOP;
  RAISE NOTICE '    TRIGGERS cloned: %', LPAD(cnt::text, 5, ' ');


  IF src_path_old = '' OR src_path_old = '""' THEN
    -- RAISE NOTICE 'Restoring old search_path to empty string';
    SELECT set_config('search_path', '', false) into v_dummy;
  ELSE
    -- RAISE NOTICE 'Restoring old search_path to:%', src_path_old;
    EXECUTE 'SET search_path = ' || src_path_old;
  END IF;
  SELECT setting INTO v_dummy FROM pg_settings WHERE name = 'search_path';
  IF bDebug THEN RAISE NOTICE 'DEBUG: setting search_path back to what it was: %', v_dummy; END IF;
  cnt := cast(extract(epoch from (clock_timestamp() - t)) as numeric(18,3));
  IF bVerbose THEN RAISE NOTICE 'clone_schema duration: % seconds',cnt; END IF;  

  EXCEPTION
     WHEN others THEN
     BEGIN
         GET STACKED DIAGNOSTICS v_diag1 = MESSAGE_TEXT, v_diag2 = PG_EXCEPTION_DETAIL, v_diag3 = PG_EXCEPTION_HINT, v_diag4 = RETURNED_SQLSTATE, v_diag5 = PG_CONTEXT, v_diag6 = PG_EXCEPTION_CONTEXT;
         v_ret := 'line=' || v_diag6 || '. '|| v_diag4 || '. ' || v_diag1;
         -- Issue#101: added version to exception output
         -- RAISE NOTICE 'v_diag1=%  v_diag2=%  v_diag3=%  v_diag4=%  v_diag5=%  v_diag6=%', v_diag1, v_diag2, v_diag3, v_diag4, v_diag5, v_diag6; 
         buffer2 = '';
         IF action = 'Copy Rows' AND v_diag4 = '42704' THEN
             -- Issue#105 Help user to fix the problem.
             buffer2 = 'It appears you have a USER-DEFINED column type mismatch.  Try running clone_schema with the FILECOPY option. ';
         END IF;
         IF lastsql <> '' THEN
             buffer = v_ret || E'\n'|| buffer2 || E'\nLastSQL='|| lastsql;
         ELSE
             buffer = v_ret || E'\n'|| buffer2;
         END IF;
         RAISE EXCEPTION 'Version: %  Action: %  Diagnostics: %',v_version, action, buffer;

         IF src_path_old = '' THEN
           -- RAISE NOTICE 'setting old search_path to empty string';
           SELECT set_config('search_path', '', false);
         ELSE
           -- RAISE NOTICE 'setting old search_path to:%', src_path_old;
           EXECUTE 'SET search_path = ' || src_path_old;
         END IF;

         RETURN;
     END;

RETURN;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE  COST 100;

-- ALTER FUNCTION public.clone_schema(text, text, cloneparms[]) OWNER TO postgres;
-- REVOKE ALL PRIVILEGES ON FUNCTION clone_schema(text, text, cloneparms[]) FROM public;
