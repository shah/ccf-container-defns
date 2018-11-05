--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5
-- Dumped by pg_dump version 10.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: substring_for_date(timestamp without time zone, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.substring_for_date(timestamp without time zone, integer, integer) RETURNS text
    LANGUAGE sql
    AS $_$SELECT SUBSTRING(CAST($1 AS text), $2, $3)$_$;


ALTER FUNCTION public.substring_for_date(timestamp without time zone, integer, integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ttrss_access_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_access_keys (
    id integer NOT NULL,
    access_key character varying(250) NOT NULL,
    feed_id character varying(250) NOT NULL,
    is_cat boolean DEFAULT false NOT NULL,
    owner_uid integer NOT NULL
);


ALTER TABLE public.ttrss_access_keys OWNER TO postgres;

--
-- Name: ttrss_access_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_access_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_access_keys_id_seq OWNER TO postgres;

--
-- Name: ttrss_access_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_access_keys_id_seq OWNED BY public.ttrss_access_keys.id;


--
-- Name: ttrss_archived_feeds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_archived_feeds (
    id integer NOT NULL,
    owner_uid integer NOT NULL,
    title character varying(200) NOT NULL,
    feed_url text NOT NULL,
    site_url character varying(250) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.ttrss_archived_feeds OWNER TO postgres;

--
-- Name: ttrss_cat_counters_cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_cat_counters_cache (
    feed_id integer NOT NULL,
    owner_uid integer NOT NULL,
    updated timestamp without time zone NOT NULL,
    value integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.ttrss_cat_counters_cache OWNER TO postgres;

--
-- Name: ttrss_counters_cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_counters_cache (
    feed_id integer NOT NULL,
    owner_uid integer NOT NULL,
    updated timestamp without time zone NOT NULL,
    value integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.ttrss_counters_cache OWNER TO postgres;

--
-- Name: ttrss_enclosures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_enclosures (
    id integer NOT NULL,
    content_url text NOT NULL,
    content_type character varying(250) NOT NULL,
    title text NOT NULL,
    duration text NOT NULL,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL,
    post_id integer NOT NULL
);


ALTER TABLE public.ttrss_enclosures OWNER TO postgres;

--
-- Name: ttrss_enclosures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_enclosures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_enclosures_id_seq OWNER TO postgres;

--
-- Name: ttrss_enclosures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_enclosures_id_seq OWNED BY public.ttrss_enclosures.id;


--
-- Name: ttrss_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_entries (
    id integer NOT NULL,
    title text NOT NULL,
    guid text NOT NULL,
    link text NOT NULL,
    updated timestamp without time zone NOT NULL,
    content text NOT NULL,
    content_hash character varying(250) NOT NULL,
    cached_content text,
    no_orig_date boolean DEFAULT false NOT NULL,
    date_entered timestamp without time zone NOT NULL,
    date_updated timestamp without time zone NOT NULL,
    num_comments integer DEFAULT 0 NOT NULL,
    comments character varying(250) DEFAULT ''::character varying NOT NULL,
    plugin_data text,
    tsvector_combined tsvector,
    lang character varying(2),
    author character varying(250) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.ttrss_entries OWNER TO postgres;

--
-- Name: ttrss_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_entries_id_seq OWNER TO postgres;

--
-- Name: ttrss_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_entries_id_seq OWNED BY public.ttrss_entries.id;


--
-- Name: ttrss_entry_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_entry_comments (
    id integer NOT NULL,
    ref_id integer NOT NULL,
    owner_uid integer NOT NULL,
    private boolean DEFAULT false NOT NULL,
    date_entered timestamp without time zone NOT NULL
);


ALTER TABLE public.ttrss_entry_comments OWNER TO postgres;

--
-- Name: ttrss_entry_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_entry_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_entry_comments_id_seq OWNER TO postgres;

--
-- Name: ttrss_entry_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_entry_comments_id_seq OWNED BY public.ttrss_entry_comments.id;


--
-- Name: ttrss_error_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_error_log (
    id integer NOT NULL,
    owner_uid integer,
    errno integer NOT NULL,
    errstr text NOT NULL,
    filename text NOT NULL,
    lineno integer NOT NULL,
    context text NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ttrss_error_log OWNER TO postgres;

--
-- Name: ttrss_error_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_error_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_error_log_id_seq OWNER TO postgres;

--
-- Name: ttrss_error_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_error_log_id_seq OWNED BY public.ttrss_error_log.id;


--
-- Name: ttrss_feed_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_feed_categories (
    id integer NOT NULL,
    owner_uid integer NOT NULL,
    collapsed boolean DEFAULT false NOT NULL,
    order_id integer DEFAULT 0 NOT NULL,
    view_settings character varying(250) DEFAULT ''::character varying NOT NULL,
    parent_cat integer,
    title character varying(200) NOT NULL
);


ALTER TABLE public.ttrss_feed_categories OWNER TO postgres;

--
-- Name: ttrss_feed_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_feed_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_feed_categories_id_seq OWNER TO postgres;

--
-- Name: ttrss_feed_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_feed_categories_id_seq OWNED BY public.ttrss_feed_categories.id;


--
-- Name: ttrss_feedbrowser_cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_feedbrowser_cache (
    feed_url text NOT NULL,
    title text NOT NULL,
    site_url text NOT NULL,
    subscribers integer NOT NULL
);


ALTER TABLE public.ttrss_feedbrowser_cache OWNER TO postgres;

--
-- Name: ttrss_feeds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_feeds (
    id integer NOT NULL,
    owner_uid integer NOT NULL,
    title character varying(200) NOT NULL,
    cat_id integer,
    feed_url text NOT NULL,
    icon_url character varying(250) DEFAULT ''::character varying NOT NULL,
    update_interval integer DEFAULT 0 NOT NULL,
    purge_interval integer DEFAULT 0 NOT NULL,
    last_updated timestamp without time zone,
    last_unconditional timestamp without time zone,
    last_error text DEFAULT ''::text NOT NULL,
    last_modified text DEFAULT ''::text NOT NULL,
    favicon_avg_color character varying(11) DEFAULT NULL::character varying,
    site_url character varying(250) DEFAULT ''::character varying NOT NULL,
    auth_login character varying(250) DEFAULT ''::character varying NOT NULL,
    parent_feed integer,
    private boolean DEFAULT false NOT NULL,
    auth_pass character varying(250) DEFAULT ''::character varying NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    include_in_digest boolean DEFAULT true NOT NULL,
    rtl_content boolean DEFAULT false NOT NULL,
    cache_images boolean DEFAULT false NOT NULL,
    hide_images boolean DEFAULT false NOT NULL,
    cache_content boolean DEFAULT false NOT NULL,
    last_viewed timestamp without time zone,
    last_update_started timestamp without time zone,
    update_method integer DEFAULT 0 NOT NULL,
    always_display_enclosures boolean DEFAULT false NOT NULL,
    order_id integer DEFAULT 0 NOT NULL,
    mark_unread_on_update boolean DEFAULT false NOT NULL,
    update_on_checksum_change boolean DEFAULT false NOT NULL,
    strip_images boolean DEFAULT false NOT NULL,
    view_settings character varying(250) DEFAULT ''::character varying NOT NULL,
    pubsub_state integer DEFAULT 0 NOT NULL,
    favicon_last_checked timestamp without time zone,
    feed_language character varying(100) DEFAULT ''::character varying NOT NULL,
    auth_pass_encrypted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.ttrss_feeds OWNER TO postgres;

--
-- Name: ttrss_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_feeds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_feeds_id_seq OWNER TO postgres;

--
-- Name: ttrss_feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_feeds_id_seq OWNED BY public.ttrss_feeds.id;


--
-- Name: ttrss_filter_actions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_filter_actions (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    description character varying(250) NOT NULL
);


ALTER TABLE public.ttrss_filter_actions OWNER TO postgres;

--
-- Name: ttrss_filter_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_filter_types (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    description character varying(250) NOT NULL
);


ALTER TABLE public.ttrss_filter_types OWNER TO postgres;

--
-- Name: ttrss_filters2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_filters2 (
    id integer NOT NULL,
    owner_uid integer NOT NULL,
    match_any_rule boolean DEFAULT false NOT NULL,
    inverse boolean DEFAULT false NOT NULL,
    title character varying(250) DEFAULT ''::character varying NOT NULL,
    order_id integer DEFAULT 0 NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.ttrss_filters2 OWNER TO postgres;

--
-- Name: ttrss_filters2_actions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_filters2_actions (
    id integer NOT NULL,
    filter_id integer NOT NULL,
    action_id integer DEFAULT 1 NOT NULL,
    action_param character varying(250) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.ttrss_filters2_actions OWNER TO postgres;

--
-- Name: ttrss_filters2_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_filters2_actions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_filters2_actions_id_seq OWNER TO postgres;

--
-- Name: ttrss_filters2_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_filters2_actions_id_seq OWNED BY public.ttrss_filters2_actions.id;


--
-- Name: ttrss_filters2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_filters2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_filters2_id_seq OWNER TO postgres;

--
-- Name: ttrss_filters2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_filters2_id_seq OWNED BY public.ttrss_filters2.id;


--
-- Name: ttrss_filters2_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_filters2_rules (
    id integer NOT NULL,
    filter_id integer NOT NULL,
    reg_exp text NOT NULL,
    inverse boolean DEFAULT false NOT NULL,
    filter_type integer NOT NULL,
    feed_id integer,
    cat_id integer,
    match_on text,
    cat_filter boolean DEFAULT false NOT NULL
);


ALTER TABLE public.ttrss_filters2_rules OWNER TO postgres;

--
-- Name: ttrss_filters2_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_filters2_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_filters2_rules_id_seq OWNER TO postgres;

--
-- Name: ttrss_filters2_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_filters2_rules_id_seq OWNED BY public.ttrss_filters2_rules.id;


--
-- Name: ttrss_labels2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_labels2 (
    id integer NOT NULL,
    owner_uid integer NOT NULL,
    fg_color character varying(15) DEFAULT ''::character varying NOT NULL,
    bg_color character varying(15) DEFAULT ''::character varying NOT NULL,
    caption character varying(250) NOT NULL
);


ALTER TABLE public.ttrss_labels2 OWNER TO postgres;

--
-- Name: ttrss_labels2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_labels2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_labels2_id_seq OWNER TO postgres;

--
-- Name: ttrss_labels2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_labels2_id_seq OWNED BY public.ttrss_labels2.id;


--
-- Name: ttrss_linked_feeds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_linked_feeds (
    feed_url text NOT NULL,
    site_url text NOT NULL,
    title text NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    instance_id integer NOT NULL,
    subscribers integer NOT NULL
);


ALTER TABLE public.ttrss_linked_feeds OWNER TO postgres;

--
-- Name: ttrss_linked_instances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_linked_instances (
    id integer NOT NULL,
    last_connected timestamp without time zone NOT NULL,
    last_status_in integer NOT NULL,
    last_status_out integer NOT NULL,
    access_key character varying(250) NOT NULL,
    access_url text NOT NULL
);


ALTER TABLE public.ttrss_linked_instances OWNER TO postgres;

--
-- Name: ttrss_linked_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_linked_instances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_linked_instances_id_seq OWNER TO postgres;

--
-- Name: ttrss_linked_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_linked_instances_id_seq OWNED BY public.ttrss_linked_instances.id;


--
-- Name: ttrss_plugin_storage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_plugin_storage (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    owner_uid integer NOT NULL,
    content text NOT NULL
);


ALTER TABLE public.ttrss_plugin_storage OWNER TO postgres;

--
-- Name: ttrss_plugin_storage_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_plugin_storage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_plugin_storage_id_seq OWNER TO postgres;

--
-- Name: ttrss_plugin_storage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_plugin_storage_id_seq OWNED BY public.ttrss_plugin_storage.id;


--
-- Name: ttrss_prefs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_prefs (
    pref_name character varying(250) NOT NULL,
    type_id integer NOT NULL,
    section_id integer DEFAULT 1 NOT NULL,
    access_level integer DEFAULT 0 NOT NULL,
    def_value text NOT NULL
);


ALTER TABLE public.ttrss_prefs OWNER TO postgres;

--
-- Name: ttrss_prefs_sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_prefs_sections (
    id integer NOT NULL,
    order_id integer NOT NULL,
    section_name character varying(100) NOT NULL
);


ALTER TABLE public.ttrss_prefs_sections OWNER TO postgres;

--
-- Name: ttrss_prefs_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_prefs_types (
    id integer NOT NULL,
    type_name character varying(100) NOT NULL
);


ALTER TABLE public.ttrss_prefs_types OWNER TO postgres;

--
-- Name: ttrss_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_sessions (
    id character varying(250) NOT NULL,
    data text,
    expire integer NOT NULL
);


ALTER TABLE public.ttrss_sessions OWNER TO postgres;

--
-- Name: ttrss_settings_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_settings_profiles (
    id integer NOT NULL,
    title character varying(250) NOT NULL,
    owner_uid integer NOT NULL
);


ALTER TABLE public.ttrss_settings_profiles OWNER TO postgres;

--
-- Name: ttrss_settings_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_settings_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_settings_profiles_id_seq OWNER TO postgres;

--
-- Name: ttrss_settings_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_settings_profiles_id_seq OWNED BY public.ttrss_settings_profiles.id;


--
-- Name: ttrss_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_tags (
    id integer NOT NULL,
    tag_name character varying(250) NOT NULL,
    owner_uid integer NOT NULL,
    post_int_id integer NOT NULL
);


ALTER TABLE public.ttrss_tags OWNER TO postgres;

--
-- Name: ttrss_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_tags_id_seq OWNER TO postgres;

--
-- Name: ttrss_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_tags_id_seq OWNED BY public.ttrss_tags.id;


--
-- Name: ttrss_user_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_user_entries (
    int_id integer NOT NULL,
    ref_id integer NOT NULL,
    uuid character varying(200) NOT NULL,
    feed_id integer,
    orig_feed_id integer,
    owner_uid integer NOT NULL,
    marked boolean DEFAULT false NOT NULL,
    published boolean DEFAULT false NOT NULL,
    tag_cache text NOT NULL,
    label_cache text NOT NULL,
    last_read timestamp without time zone,
    score integer DEFAULT 0 NOT NULL,
    last_marked timestamp without time zone,
    last_published timestamp without time zone,
    note text,
    unread boolean DEFAULT true NOT NULL
);


ALTER TABLE public.ttrss_user_entries OWNER TO postgres;

--
-- Name: ttrss_user_entries_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_user_entries_int_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_user_entries_int_id_seq OWNER TO postgres;

--
-- Name: ttrss_user_entries_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_user_entries_int_id_seq OWNED BY public.ttrss_user_entries.int_id;


--
-- Name: ttrss_user_labels2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_user_labels2 (
    label_id integer NOT NULL,
    article_id integer NOT NULL
);


ALTER TABLE public.ttrss_user_labels2 OWNER TO postgres;

--
-- Name: ttrss_user_prefs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_user_prefs (
    owner_uid integer NOT NULL,
    pref_name character varying(250) NOT NULL,
    profile integer,
    value text NOT NULL
);


ALTER TABLE public.ttrss_user_prefs OWNER TO postgres;

--
-- Name: ttrss_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_users (
    id integer NOT NULL,
    login character varying(120) NOT NULL,
    pwd_hash character varying(250) NOT NULL,
    last_login timestamp without time zone,
    access_level integer DEFAULT 0 NOT NULL,
    email character varying(250) DEFAULT ''::character varying NOT NULL,
    full_name character varying(250) DEFAULT ''::character varying NOT NULL,
    email_digest boolean DEFAULT false NOT NULL,
    last_digest_sent timestamp without time zone,
    salt character varying(250) DEFAULT ''::character varying NOT NULL,
    twitter_oauth text,
    otp_enabled boolean DEFAULT false NOT NULL,
    resetpass_token character varying(250) DEFAULT NULL::character varying,
    created timestamp without time zone
);


ALTER TABLE public.ttrss_users OWNER TO postgres;

--
-- Name: ttrss_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ttrss_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ttrss_users_id_seq OWNER TO postgres;

--
-- Name: ttrss_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ttrss_users_id_seq OWNED BY public.ttrss_users.id;


--
-- Name: ttrss_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ttrss_version (
    schema_version integer NOT NULL
);


ALTER TABLE public.ttrss_version OWNER TO postgres;

--
-- Name: ttrss_access_keys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_access_keys ALTER COLUMN id SET DEFAULT nextval('public.ttrss_access_keys_id_seq'::regclass);


--
-- Name: ttrss_enclosures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_enclosures ALTER COLUMN id SET DEFAULT nextval('public.ttrss_enclosures_id_seq'::regclass);


--
-- Name: ttrss_entries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_entries ALTER COLUMN id SET DEFAULT nextval('public.ttrss_entries_id_seq'::regclass);


--
-- Name: ttrss_entry_comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_entry_comments ALTER COLUMN id SET DEFAULT nextval('public.ttrss_entry_comments_id_seq'::regclass);


--
-- Name: ttrss_error_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_error_log ALTER COLUMN id SET DEFAULT nextval('public.ttrss_error_log_id_seq'::regclass);


--
-- Name: ttrss_feed_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feed_categories ALTER COLUMN id SET DEFAULT nextval('public.ttrss_feed_categories_id_seq'::regclass);


--
-- Name: ttrss_feeds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feeds ALTER COLUMN id SET DEFAULT nextval('public.ttrss_feeds_id_seq'::regclass);


--
-- Name: ttrss_filters2 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2 ALTER COLUMN id SET DEFAULT nextval('public.ttrss_filters2_id_seq'::regclass);


--
-- Name: ttrss_filters2_actions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_actions ALTER COLUMN id SET DEFAULT nextval('public.ttrss_filters2_actions_id_seq'::regclass);


--
-- Name: ttrss_filters2_rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_rules ALTER COLUMN id SET DEFAULT nextval('public.ttrss_filters2_rules_id_seq'::regclass);


--
-- Name: ttrss_labels2 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_labels2 ALTER COLUMN id SET DEFAULT nextval('public.ttrss_labels2_id_seq'::regclass);


--
-- Name: ttrss_linked_instances id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_linked_instances ALTER COLUMN id SET DEFAULT nextval('public.ttrss_linked_instances_id_seq'::regclass);


--
-- Name: ttrss_plugin_storage id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_plugin_storage ALTER COLUMN id SET DEFAULT nextval('public.ttrss_plugin_storage_id_seq'::regclass);


--
-- Name: ttrss_settings_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_settings_profiles ALTER COLUMN id SET DEFAULT nextval('public.ttrss_settings_profiles_id_seq'::regclass);


--
-- Name: ttrss_tags id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_tags ALTER COLUMN id SET DEFAULT nextval('public.ttrss_tags_id_seq'::regclass);


--
-- Name: ttrss_user_entries int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_entries ALTER COLUMN int_id SET DEFAULT nextval('public.ttrss_user_entries_int_id_seq'::regclass);


--
-- Name: ttrss_users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_users ALTER COLUMN id SET DEFAULT nextval('public.ttrss_users_id_seq'::regclass);


--
-- Data for Name: ttrss_access_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_access_keys (id, access_key, feed_id, is_cat, owner_uid) FROM stdin;
\.


--
-- Data for Name: ttrss_archived_feeds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_archived_feeds (id, owner_uid, title, feed_url, site_url) FROM stdin;
\.


--
-- Data for Name: ttrss_cat_counters_cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_cat_counters_cache (feed_id, owner_uid, updated, value) FROM stdin;
\.


--
-- Data for Name: ttrss_counters_cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_counters_cache (feed_id, owner_uid, updated, value) FROM stdin;
\.


--
-- Data for Name: ttrss_enclosures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_enclosures (id, content_url, content_type, title, duration, width, height, post_id) FROM stdin;
\.


--
-- Data for Name: ttrss_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_entries (id, title, guid, link, updated, content, content_hash, cached_content, no_orig_date, date_entered, date_updated, num_comments, comments, plugin_data, tsvector_combined, lang, author) FROM stdin;
\.


--
-- Data for Name: ttrss_entry_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_entry_comments (id, ref_id, owner_uid, private, date_entered) FROM stdin;
\.


--
-- Data for Name: ttrss_error_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_error_log (id, owner_uid, errno, errstr, filename, lineno, context, created_at) FROM stdin;
\.


--
-- Data for Name: ttrss_feed_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_feed_categories (id, owner_uid, collapsed, order_id, view_settings, parent_cat, title) FROM stdin;
\.


--
-- Data for Name: ttrss_feedbrowser_cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_feedbrowser_cache (feed_url, title, site_url, subscribers) FROM stdin;
http://tt-rss.org/forum/rss.php	Tiny Tiny RSS: Forum		1
\.


--
-- Data for Name: ttrss_feeds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_feeds (id, owner_uid, title, cat_id, feed_url, icon_url, update_interval, purge_interval, last_updated, last_unconditional, last_error, last_modified, favicon_avg_color, site_url, auth_login, parent_feed, private, auth_pass, hidden, include_in_digest, rtl_content, cache_images, hide_images, cache_content, last_viewed, last_update_started, update_method, always_display_enclosures, order_id, mark_unread_on_update, update_on_checksum_change, strip_images, view_settings, pubsub_state, favicon_last_checked, feed_language, auth_pass_encrypted) FROM stdin;
1	1	Tiny Tiny RSS: Forum	\N	http://tt-rss.org/forum/rss.php		0	0	\N	\N			\N			\N	f		f	t	f	f	f	f	\N	\N	0	f	0	f	f	f		0	\N		f
\.


--
-- Data for Name: ttrss_filter_actions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_filter_actions (id, name, description) FROM stdin;
1	filter	Delete article
2	catchup	Mark as read
3	mark	Set starred
4	tag	Assign tags
5	publish	Publish article
6	score	Modify score
7	label	Assign label
8	stop	Stop / Do nothing
9	plugin	Invoke plugin
\.


--
-- Data for Name: ttrss_filter_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_filter_types (id, name, description) FROM stdin;
1	title	Title
2	content	Content
3	both	Title or Content
4	link	Link
5	date	Article Date
6	author	Author
7	tag	Article Tags
\.


--
-- Data for Name: ttrss_filters2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_filters2 (id, owner_uid, match_any_rule, inverse, title, order_id, enabled) FROM stdin;
\.


--
-- Data for Name: ttrss_filters2_actions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_filters2_actions (id, filter_id, action_id, action_param) FROM stdin;
\.


--
-- Data for Name: ttrss_filters2_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_filters2_rules (id, filter_id, reg_exp, inverse, filter_type, feed_id, cat_id, match_on, cat_filter) FROM stdin;
\.


--
-- Data for Name: ttrss_labels2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_labels2 (id, owner_uid, fg_color, bg_color, caption) FROM stdin;
\.


--
-- Data for Name: ttrss_linked_feeds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_linked_feeds (feed_url, site_url, title, created, updated, instance_id, subscribers) FROM stdin;
\.


--
-- Data for Name: ttrss_linked_instances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_linked_instances (id, last_connected, last_status_in, last_status_out, access_key, access_url) FROM stdin;
\.


--
-- Data for Name: ttrss_plugin_storage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_plugin_storage (id, name, owner_uid, content) FROM stdin;
\.


--
-- Data for Name: ttrss_prefs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_prefs (pref_name, type_id, section_id, access_level, def_value) FROM stdin;
PURGE_OLD_DAYS	3	1	0	60
DEFAULT_UPDATE_INTERVAL	3	1	0	30
DEFAULT_ARTICLE_LIMIT	3	2	0	30
ALLOW_DUPLICATE_POSTS	1	1	0	false
ENABLE_FEED_CATS	1	2	0	true
SHORT_DATE_FORMAT	2	3	0	M d, G:i
LONG_DATE_FORMAT	2	3	0	D, M d Y - G:i
COMBINED_DISPLAY_MODE	1	2	0	true
HIDE_READ_FEEDS	1	2	0	false
FEEDS_SORT_BY_UNREAD	1	2	0	false
REVERSE_HEADLINES	1	2	0	false
DIGEST_ENABLE	1	4	0	false
CONFIRM_FEED_CATCHUP	1	2	0	true
CDM_AUTO_CATCHUP	1	2	0	false
_DEFAULT_VIEW_MODE	2	1	0	adaptive
_DEFAULT_VIEW_LIMIT	3	1	0	30
_PREFS_ACTIVE_TAB	2	1	0	
STRIP_UNSAFE_TAGS	1	3	0	true
BLACKLISTED_TAGS	2	3	0	main, generic, misc, uncategorized, blog, blogroll, general, news
DIGEST_CATCHUP	1	4	0	false
PURGE_UNREAD_ARTICLES	1	3	0	true
STRIP_IMAGES	1	2	0	false
_DEFAULT_VIEW_ORDER_BY	2	1	0	default
ENABLE_API_ACCESS	1	1	0	false
_COLLAPSED_SPECIAL	1	1	0	false
_COLLAPSED_LABELS	1	1	0	false
_COLLAPSED_UNCAT	1	1	0	false
_COLLAPSED_FEEDLIST	1	1	0	false
_MOBILE_ENABLE_CATS	1	1	0	false
_MOBILE_SHOW_IMAGES	1	1	0	false
_MOBILE_HIDE_READ	1	1	0	false
_MOBILE_SORT_FEEDS_UNREAD	1	1	0	false
_THEME_ID	2	1	0	0
USER_TIMEZONE	2	1	0	Automatic
USER_STYLESHEET	2	2	0	
_MOBILE_BROWSE_CATS	1	1	0	true
SSL_CERT_SERIAL	2	3	0	
DIGEST_PREFERRED_TIME	2	4	0	00:00
_PREFS_SHOW_EMPTY_CATS	1	1	0	false
_DEFAULT_INCLUDE_CHILDREN	1	1	0	false
_ENABLED_PLUGINS	2	1	0	
_MOBILE_REVERSE_HEADLINES	1	1	0	false
USER_CSS_THEME	2	2	0	
USER_LANGUAGE	2	2	0	
SHOW_CONTENT_PREVIEW	1	2	1	true
ON_CATCHUP_SHOW_NEXT_FEED	1	2	1	false
FRESH_ARTICLE_MAX_AGE	3	2	1	24
CDM_EXPANDED	1	2	1	true
HIDE_READ_SHOWS_SPECIAL	1	2	1	true
VFEED_GROUP_BY_FEED	1	2	1	false
SORT_HEADLINES_BY_FEED_DATE	1	2	1	false
AUTO_ASSIGN_LABELS	1	3	1	false
\.


--
-- Data for Name: ttrss_prefs_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_prefs_sections (id, order_id, section_name) FROM stdin;
1	0	General
2	1	Interface
3	3	Advanced
4	2	Digest
\.


--
-- Data for Name: ttrss_prefs_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_prefs_types (id, type_name) FROM stdin;
1	bool
2	string
3	integer
\.


--
-- Data for Name: ttrss_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_sessions (id, data, expire) FROM stdin;
\.


--
-- Data for Name: ttrss_settings_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_settings_profiles (id, title, owner_uid) FROM stdin;
\.


--
-- Data for Name: ttrss_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_tags (id, tag_name, owner_uid, post_int_id) FROM stdin;
\.


--
-- Data for Name: ttrss_user_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_user_entries (int_id, ref_id, uuid, feed_id, orig_feed_id, owner_uid, marked, published, tag_cache, label_cache, last_read, score, last_marked, last_published, note, unread) FROM stdin;
\.


--
-- Data for Name: ttrss_user_labels2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_user_labels2 (label_id, article_id) FROM stdin;
\.


--
-- Data for Name: ttrss_user_prefs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_user_prefs (owner_uid, pref_name, profile, value) FROM stdin;
\.


--
-- Data for Name: ttrss_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_users (id, login, pwd_hash, last_login, access_level, email, full_name, email_digest, last_digest_sent, salt, twitter_oauth, otp_enabled, resetpass_token, created) FROM stdin;
1	admin	SHA1:5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8	\N	10			f	\N		\N	f	\N	\N
\.


--
-- Data for Name: ttrss_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ttrss_version (schema_version) FROM stdin;
134
\.


--
-- Name: ttrss_access_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_access_keys_id_seq', 1, false);


--
-- Name: ttrss_enclosures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_enclosures_id_seq', 1, false);


--
-- Name: ttrss_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_entries_id_seq', 1, false);


--
-- Name: ttrss_entry_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_entry_comments_id_seq', 1, false);


--
-- Name: ttrss_error_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_error_log_id_seq', 1, false);


--
-- Name: ttrss_feed_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_feed_categories_id_seq', 1, false);


--
-- Name: ttrss_feeds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_feeds_id_seq', 1, true);


--
-- Name: ttrss_filters2_actions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_filters2_actions_id_seq', 1, false);


--
-- Name: ttrss_filters2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_filters2_id_seq', 1, false);


--
-- Name: ttrss_filters2_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_filters2_rules_id_seq', 1, false);


--
-- Name: ttrss_labels2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_labels2_id_seq', 1, false);


--
-- Name: ttrss_linked_instances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_linked_instances_id_seq', 1, false);


--
-- Name: ttrss_plugin_storage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_plugin_storage_id_seq', 1, false);


--
-- Name: ttrss_settings_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_settings_profiles_id_seq', 1, false);


--
-- Name: ttrss_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_tags_id_seq', 1, false);


--
-- Name: ttrss_user_entries_int_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_user_entries_int_id_seq', 1, false);


--
-- Name: ttrss_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ttrss_users_id_seq', 1, true);


--
-- Name: ttrss_access_keys ttrss_access_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_access_keys
    ADD CONSTRAINT ttrss_access_keys_pkey PRIMARY KEY (id);


--
-- Name: ttrss_archived_feeds ttrss_archived_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_archived_feeds
    ADD CONSTRAINT ttrss_archived_feeds_pkey PRIMARY KEY (id);


--
-- Name: ttrss_enclosures ttrss_enclosures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_enclosures
    ADD CONSTRAINT ttrss_enclosures_pkey PRIMARY KEY (id);


--
-- Name: ttrss_entries ttrss_entries_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_entries
    ADD CONSTRAINT ttrss_entries_guid_key UNIQUE (guid);


--
-- Name: ttrss_entries ttrss_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_entries
    ADD CONSTRAINT ttrss_entries_pkey PRIMARY KEY (id);


--
-- Name: ttrss_entry_comments ttrss_entry_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_entry_comments
    ADD CONSTRAINT ttrss_entry_comments_pkey PRIMARY KEY (id);


--
-- Name: ttrss_error_log ttrss_error_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_error_log
    ADD CONSTRAINT ttrss_error_log_pkey PRIMARY KEY (id);


--
-- Name: ttrss_feed_categories ttrss_feed_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feed_categories
    ADD CONSTRAINT ttrss_feed_categories_pkey PRIMARY KEY (id);


--
-- Name: ttrss_feedbrowser_cache ttrss_feedbrowser_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feedbrowser_cache
    ADD CONSTRAINT ttrss_feedbrowser_cache_pkey PRIMARY KEY (feed_url);


--
-- Name: ttrss_feeds ttrss_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feeds
    ADD CONSTRAINT ttrss_feeds_pkey PRIMARY KEY (id);


--
-- Name: ttrss_filter_actions ttrss_filter_actions_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filter_actions
    ADD CONSTRAINT ttrss_filter_actions_description_key UNIQUE (description);


--
-- Name: ttrss_filter_actions ttrss_filter_actions_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filter_actions
    ADD CONSTRAINT ttrss_filter_actions_name_key UNIQUE (name);


--
-- Name: ttrss_filter_actions ttrss_filter_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filter_actions
    ADD CONSTRAINT ttrss_filter_actions_pkey PRIMARY KEY (id);


--
-- Name: ttrss_filter_types ttrss_filter_types_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filter_types
    ADD CONSTRAINT ttrss_filter_types_description_key UNIQUE (description);


--
-- Name: ttrss_filter_types ttrss_filter_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filter_types
    ADD CONSTRAINT ttrss_filter_types_name_key UNIQUE (name);


--
-- Name: ttrss_filter_types ttrss_filter_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filter_types
    ADD CONSTRAINT ttrss_filter_types_pkey PRIMARY KEY (id);


--
-- Name: ttrss_filters2_actions ttrss_filters2_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_actions
    ADD CONSTRAINT ttrss_filters2_actions_pkey PRIMARY KEY (id);


--
-- Name: ttrss_filters2 ttrss_filters2_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2
    ADD CONSTRAINT ttrss_filters2_pkey PRIMARY KEY (id);


--
-- Name: ttrss_filters2_rules ttrss_filters2_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_rules
    ADD CONSTRAINT ttrss_filters2_rules_pkey PRIMARY KEY (id);


--
-- Name: ttrss_labels2 ttrss_labels2_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_labels2
    ADD CONSTRAINT ttrss_labels2_pkey PRIMARY KEY (id);


--
-- Name: ttrss_linked_instances ttrss_linked_instances_access_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_linked_instances
    ADD CONSTRAINT ttrss_linked_instances_access_key_key UNIQUE (access_key);


--
-- Name: ttrss_linked_instances ttrss_linked_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_linked_instances
    ADD CONSTRAINT ttrss_linked_instances_pkey PRIMARY KEY (id);


--
-- Name: ttrss_plugin_storage ttrss_plugin_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_plugin_storage
    ADD CONSTRAINT ttrss_plugin_storage_pkey PRIMARY KEY (id);


--
-- Name: ttrss_prefs ttrss_prefs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_prefs
    ADD CONSTRAINT ttrss_prefs_pkey PRIMARY KEY (pref_name);


--
-- Name: ttrss_prefs_sections ttrss_prefs_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_prefs_sections
    ADD CONSTRAINT ttrss_prefs_sections_pkey PRIMARY KEY (id);


--
-- Name: ttrss_prefs_types ttrss_prefs_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_prefs_types
    ADD CONSTRAINT ttrss_prefs_types_pkey PRIMARY KEY (id);


--
-- Name: ttrss_sessions ttrss_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_sessions
    ADD CONSTRAINT ttrss_sessions_pkey PRIMARY KEY (id);


--
-- Name: ttrss_settings_profiles ttrss_settings_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_settings_profiles
    ADD CONSTRAINT ttrss_settings_profiles_pkey PRIMARY KEY (id);


--
-- Name: ttrss_tags ttrss_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_tags
    ADD CONSTRAINT ttrss_tags_pkey PRIMARY KEY (id);


--
-- Name: ttrss_user_entries ttrss_user_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_entries
    ADD CONSTRAINT ttrss_user_entries_pkey PRIMARY KEY (int_id);


--
-- Name: ttrss_users ttrss_users_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_users
    ADD CONSTRAINT ttrss_users_login_key UNIQUE (login);


--
-- Name: ttrss_users ttrss_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_users
    ADD CONSTRAINT ttrss_users_pkey PRIMARY KEY (id);


--
-- Name: ttrss_cat_counters_cache_owner_uid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_cat_counters_cache_owner_uid_idx ON public.ttrss_cat_counters_cache USING btree (owner_uid);


--
-- Name: ttrss_counters_cache_feed_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_counters_cache_feed_id_idx ON public.ttrss_counters_cache USING btree (feed_id);


--
-- Name: ttrss_counters_cache_owner_uid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_counters_cache_owner_uid_idx ON public.ttrss_counters_cache USING btree (owner_uid);


--
-- Name: ttrss_counters_cache_value_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_counters_cache_value_idx ON public.ttrss_counters_cache USING btree (value);


--
-- Name: ttrss_enclosures_post_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_enclosures_post_id_idx ON public.ttrss_enclosures USING btree (post_id);


--
-- Name: ttrss_entries_date_entered_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_entries_date_entered_index ON public.ttrss_entries USING btree (date_entered);


--
-- Name: ttrss_entries_tsvector_combined_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_entries_tsvector_combined_idx ON public.ttrss_entries USING gin (tsvector_combined);


--
-- Name: ttrss_entries_updated_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_entries_updated_idx ON public.ttrss_entries USING btree (updated);


--
-- Name: ttrss_entry_comments_ref_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_entry_comments_ref_id_index ON public.ttrss_entry_comments USING btree (ref_id);


--
-- Name: ttrss_feeds_cat_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_feeds_cat_id_idx ON public.ttrss_feeds USING btree (cat_id);


--
-- Name: ttrss_feeds_owner_uid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_feeds_owner_uid_index ON public.ttrss_feeds USING btree (owner_uid);


--
-- Name: ttrss_sessions_expire_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_sessions_expire_index ON public.ttrss_sessions USING btree (expire);


--
-- Name: ttrss_tags_owner_uid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_tags_owner_uid_index ON public.ttrss_tags USING btree (owner_uid);


--
-- Name: ttrss_tags_post_int_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_tags_post_int_id_idx ON public.ttrss_tags USING btree (post_int_id);


--
-- Name: ttrss_user_entries_feed_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_user_entries_feed_id ON public.ttrss_user_entries USING btree (feed_id);


--
-- Name: ttrss_user_entries_owner_uid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_user_entries_owner_uid_index ON public.ttrss_user_entries USING btree (owner_uid);


--
-- Name: ttrss_user_entries_ref_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_user_entries_ref_id_index ON public.ttrss_user_entries USING btree (ref_id);


--
-- Name: ttrss_user_entries_unread_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_user_entries_unread_idx ON public.ttrss_user_entries USING btree (unread);


--
-- Name: ttrss_user_prefs_owner_uid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_user_prefs_owner_uid_index ON public.ttrss_user_prefs USING btree (owner_uid);


--
-- Name: ttrss_user_prefs_pref_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ttrss_user_prefs_pref_name_idx ON public.ttrss_user_prefs USING btree (pref_name);


--
-- Name: ttrss_access_keys ttrss_access_keys_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_access_keys
    ADD CONSTRAINT ttrss_access_keys_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_archived_feeds ttrss_archived_feeds_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_archived_feeds
    ADD CONSTRAINT ttrss_archived_feeds_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_cat_counters_cache ttrss_cat_counters_cache_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_cat_counters_cache
    ADD CONSTRAINT ttrss_cat_counters_cache_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_counters_cache ttrss_counters_cache_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_counters_cache
    ADD CONSTRAINT ttrss_counters_cache_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_enclosures ttrss_enclosures_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_enclosures
    ADD CONSTRAINT ttrss_enclosures_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.ttrss_entries(id) ON DELETE CASCADE;


--
-- Name: ttrss_entry_comments ttrss_entry_comments_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_entry_comments
    ADD CONSTRAINT ttrss_entry_comments_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_entry_comments ttrss_entry_comments_ref_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_entry_comments
    ADD CONSTRAINT ttrss_entry_comments_ref_id_fkey FOREIGN KEY (ref_id) REFERENCES public.ttrss_entries(id) ON DELETE CASCADE;


--
-- Name: ttrss_error_log ttrss_error_log_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_error_log
    ADD CONSTRAINT ttrss_error_log_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE SET NULL;


--
-- Name: ttrss_feed_categories ttrss_feed_categories_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feed_categories
    ADD CONSTRAINT ttrss_feed_categories_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_feed_categories ttrss_feed_categories_parent_cat_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feed_categories
    ADD CONSTRAINT ttrss_feed_categories_parent_cat_fkey FOREIGN KEY (parent_cat) REFERENCES public.ttrss_feed_categories(id) ON DELETE SET NULL;


--
-- Name: ttrss_feeds ttrss_feeds_cat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feeds
    ADD CONSTRAINT ttrss_feeds_cat_id_fkey FOREIGN KEY (cat_id) REFERENCES public.ttrss_feed_categories(id) ON DELETE SET NULL;


--
-- Name: ttrss_feeds ttrss_feeds_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feeds
    ADD CONSTRAINT ttrss_feeds_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_feeds ttrss_feeds_parent_feed_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_feeds
    ADD CONSTRAINT ttrss_feeds_parent_feed_fkey FOREIGN KEY (parent_feed) REFERENCES public.ttrss_feeds(id) ON DELETE SET NULL;


--
-- Name: ttrss_filters2_actions ttrss_filters2_actions_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_actions
    ADD CONSTRAINT ttrss_filters2_actions_action_id_fkey FOREIGN KEY (action_id) REFERENCES public.ttrss_filter_actions(id) ON DELETE CASCADE;


--
-- Name: ttrss_filters2_actions ttrss_filters2_actions_filter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_actions
    ADD CONSTRAINT ttrss_filters2_actions_filter_id_fkey FOREIGN KEY (filter_id) REFERENCES public.ttrss_filters2(id) ON DELETE CASCADE;


--
-- Name: ttrss_filters2 ttrss_filters2_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2
    ADD CONSTRAINT ttrss_filters2_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_filters2_rules ttrss_filters2_rules_cat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_rules
    ADD CONSTRAINT ttrss_filters2_rules_cat_id_fkey FOREIGN KEY (cat_id) REFERENCES public.ttrss_feed_categories(id) ON DELETE CASCADE;


--
-- Name: ttrss_filters2_rules ttrss_filters2_rules_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_rules
    ADD CONSTRAINT ttrss_filters2_rules_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES public.ttrss_feeds(id) ON DELETE CASCADE;


--
-- Name: ttrss_filters2_rules ttrss_filters2_rules_filter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_rules
    ADD CONSTRAINT ttrss_filters2_rules_filter_id_fkey FOREIGN KEY (filter_id) REFERENCES public.ttrss_filters2(id) ON DELETE CASCADE;


--
-- Name: ttrss_filters2_rules ttrss_filters2_rules_filter_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_filters2_rules
    ADD CONSTRAINT ttrss_filters2_rules_filter_type_fkey FOREIGN KEY (filter_type) REFERENCES public.ttrss_filter_types(id);


--
-- Name: ttrss_labels2 ttrss_labels2_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_labels2
    ADD CONSTRAINT ttrss_labels2_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_linked_feeds ttrss_linked_feeds_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_linked_feeds
    ADD CONSTRAINT ttrss_linked_feeds_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.ttrss_linked_instances(id) ON DELETE CASCADE;


--
-- Name: ttrss_plugin_storage ttrss_plugin_storage_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_plugin_storage
    ADD CONSTRAINT ttrss_plugin_storage_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_prefs ttrss_prefs_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_prefs
    ADD CONSTRAINT ttrss_prefs_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.ttrss_prefs_sections(id);


--
-- Name: ttrss_prefs ttrss_prefs_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_prefs
    ADD CONSTRAINT ttrss_prefs_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.ttrss_prefs_types(id);


--
-- Name: ttrss_settings_profiles ttrss_settings_profiles_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_settings_profiles
    ADD CONSTRAINT ttrss_settings_profiles_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_tags ttrss_tags_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_tags
    ADD CONSTRAINT ttrss_tags_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_tags ttrss_tags_post_int_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_tags
    ADD CONSTRAINT ttrss_tags_post_int_id_fkey FOREIGN KEY (post_int_id) REFERENCES public.ttrss_user_entries(int_id) ON DELETE CASCADE;


--
-- Name: ttrss_user_entries ttrss_user_entries_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_entries
    ADD CONSTRAINT ttrss_user_entries_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES public.ttrss_feeds(id) ON DELETE CASCADE;


--
-- Name: ttrss_user_entries ttrss_user_entries_orig_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_entries
    ADD CONSTRAINT ttrss_user_entries_orig_feed_id_fkey FOREIGN KEY (orig_feed_id) REFERENCES public.ttrss_archived_feeds(id) ON DELETE SET NULL;


--
-- Name: ttrss_user_entries ttrss_user_entries_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_entries
    ADD CONSTRAINT ttrss_user_entries_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_user_entries ttrss_user_entries_ref_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_entries
    ADD CONSTRAINT ttrss_user_entries_ref_id_fkey FOREIGN KEY (ref_id) REFERENCES public.ttrss_entries(id) ON DELETE CASCADE;


--
-- Name: ttrss_user_labels2 ttrss_user_labels2_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_labels2
    ADD CONSTRAINT ttrss_user_labels2_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.ttrss_entries(id) ON DELETE CASCADE;


--
-- Name: ttrss_user_labels2 ttrss_user_labels2_label_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_labels2
    ADD CONSTRAINT ttrss_user_labels2_label_id_fkey FOREIGN KEY (label_id) REFERENCES public.ttrss_labels2(id) ON DELETE CASCADE;


--
-- Name: ttrss_user_prefs ttrss_user_prefs_owner_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_prefs
    ADD CONSTRAINT ttrss_user_prefs_owner_uid_fkey FOREIGN KEY (owner_uid) REFERENCES public.ttrss_users(id) ON DELETE CASCADE;


--
-- Name: ttrss_user_prefs ttrss_user_prefs_pref_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_prefs
    ADD CONSTRAINT ttrss_user_prefs_pref_name_fkey FOREIGN KEY (pref_name) REFERENCES public.ttrss_prefs(pref_name) ON DELETE CASCADE;


--
-- Name: ttrss_user_prefs ttrss_user_prefs_profile_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ttrss_user_prefs
    ADD CONSTRAINT ttrss_user_prefs_profile_fkey FOREIGN KEY (profile) REFERENCES public.ttrss_settings_profiles(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

