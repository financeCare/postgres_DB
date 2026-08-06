--
-- PostgreSQL database dump
--

\restrict eVbgE3rwbCsneIbyb9OrO30DEM95298cBkTZMkqkuwJg5hNkhzKTxbokTaBhef9

-- Dumped from database version 15.18
-- Dumped by pg_dump version 18.1

-- Started on 2026-08-06 13:18:38

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 16833)
-- Name: public; Type: SCHEMA; Schema: -; Owner: root
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO root;

--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: root
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 864 (class 1247 OID 16836)
-- Name: debt_txn_type_enum; Type: TYPE; Schema: public; Owner: root
--

CREATE TYPE public.debt_txn_type_enum AS ENUM (
    'PAYMENT',
    'INTEREST',
    'LATE_FEE',
    'PENALTY_INTEREST',
    'PRINCIPAL_ADJUSTMENT'
);


ALTER TYPE public.debt_txn_type_enum OWNER TO root;

--
-- TOC entry 867 (class 1247 OID 16848)
-- Name: fee_type_enum; Type: TYPE; Schema: public; Owner: root
--

CREATE TYPE public.fee_type_enum AS ENUM (
    'PERCENT_OUTSTANDING',
    'PERCENT_PREPAID',
    'FLAT',
    'INTEREST_LOSS',
    'THRESHOLD'
);


ALTER TYPE public.fee_type_enum OWNER TO root;

--
-- TOC entry 870 (class 1247 OID 16860)
-- Name: late_fee_type_enum; Type: TYPE; Schema: public; Owner: root
--

CREATE TYPE public.late_fee_type_enum AS ENUM (
    'FLAT',
    'PERCENT_ARREARS',
    'PENALTY_INTEREST'
);


ALTER TYPE public.late_fee_type_enum OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 214 (class 1259 OID 16867)
-- Name: budget_per_month; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.budget_per_month (
    budget_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    amount double precision NOT NULL,
    limit_budget double precision,
    month integer NOT NULL,
    year integer NOT NULL
);


ALTER TABLE public.budget_per_month OWNER TO root;

--
-- TOC entry 215 (class 1259 OID 16871)
-- Name: categories; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    user_id uuid,
    category_name character varying(30) NOT NULL,
    type character varying(10) NOT NULL,
    budget_id uuid
);


ALTER TABLE public.categories OWNER TO root;

--
-- TOC entry 216 (class 1259 OID 16874)
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO root;

--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 216
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- TOC entry 217 (class 1259 OID 16875)
-- Name: debt; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.debt (
    user_id uuid NOT NULL,
    principal_amount numeric(15,2) NOT NULL,
    interest_rate numeric(10,4) NOT NULL,
    repayment_type integer NOT NULL,
    start_date timestamp(6) without time zone NOT NULL,
    is_active boolean NOT NULL,
    priority integer NOT NULL,
    debt_type integer NOT NULL,
    debt_name character varying(255) NOT NULL,
    min_payment numeric(15,2),
    due_day integer,
    end_date timestamp(6) without time zone,
    debt_id uuid NOT NULL,
    principal_outstanding numeric(15,2),
    overpayment_balance numeric(15,2),
    interest_type smallint,
    penalty_annual_rate numeric(10,4),
    grace_period_days integer,
    penalty_trigger_days integer,
    is_defaulted boolean,
    is_informal boolean,
    interest_interval character varying(255),
    payment_interval character varying(255),
    total_interest_paid numeric(15,2),
    initial_interest_remaining numeric(15,2),
    initial_late_fee_remaining numeric(15,2),
    initial_penalty_remaining numeric(15,2),
    CONSTRAINT debt_interest_interval_check CHECK (((interest_interval)::text = ANY (ARRAY[('DAILY'::character varying)::text, ('WEEKLY'::character varying)::text, ('MONTHLY'::character varying)::text, ('YEARLY'::character varying)::text]))),
    CONSTRAINT debt_payment_interval_check CHECK (((payment_interval)::text = ANY (ARRAY[('DAILY'::character varying)::text, ('WEEKLY'::character varying)::text, ('BI_WEEKLY'::character varying)::text, ('MONTHLY'::character varying)::text])))
);


ALTER TABLE public.debt OWNER TO root;

--
-- TOC entry 218 (class 1259 OID 16882)
-- Name: debt_statement; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.debt_statement (
    statement_id uuid DEFAULT gen_random_uuid() NOT NULL,
    debt_id uuid NOT NULL,
    statement_year integer NOT NULL,
    statement_month integer NOT NULL,
    principal_snapshot numeric(15,2) NOT NULL,
    interest_charged numeric(15,2) NOT NULL,
    interest_paid numeric(15,2) DEFAULT 0 NOT NULL,
    interest_outstanding numeric(15,2) DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    principal_paid numeric(15,2) NOT NULL,
    principal_closing_balance numeric(15,2)
);


ALTER TABLE public.debt_statement OWNER TO root;

--
-- TOC entry 219 (class 1259 OID 16889)
-- Name: debt_transactions; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.debt_transactions (
    transaction_id uuid DEFAULT gen_random_uuid() NOT NULL,
    debt_id uuid NOT NULL,
    txn_type character varying(50) NOT NULL,
    amount numeric(15,2) NOT NULL,
    txn_date date NOT NULL,
    debt_arrears_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reference_id uuid,
    slip_id bigint
);


ALTER TABLE public.debt_transactions OWNER TO root;

--
-- TOC entry 220 (class 1259 OID 16894)
-- Name: debt_type; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.debt_type (
    type_id integer NOT NULL,
    type_name character varying(255),
    description character varying(255)
);


ALTER TABLE public.debt_type OWNER TO root;

--
-- TOC entry 221 (class 1259 OID 16899)
-- Name: debt_type_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.debt_type_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.debt_type_seq OWNER TO root;

--
-- TOC entry 222 (class 1259 OID 16900)
-- Name: debt_type_type_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.debt_type_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.debt_type_type_id_seq OWNER TO root;

--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 222
-- Name: debt_type_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.debt_type_type_id_seq OWNED BY public.debt_type.type_id;


--
-- TOC entry 223 (class 1259 OID 16901)
-- Name: job_applications; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.job_applications (
    id bigint NOT NULL,
    applied_at timestamp(6) without time zone,
    job_id character varying(255) NOT NULL,
    job_title character varying(255) NOT NULL,
    platform character varying(255) NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.job_applications OWNER TO root;

--
-- TOC entry 224 (class 1259 OID 16906)
-- Name: job_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.job_applications ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.job_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 16907)
-- Name: notification_log; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.notification_log (
    log_id uuid NOT NULL,
    user_id uuid NOT NULL,
    rule_id uuid,
    ref_type character varying(30),
    ref_id character varying(64),
    channel character varying(20) NOT NULL,
    status character varying(20) NOT NULL,
    title character varying(120),
    body character varying(500),
    sent_at timestamp without time zone DEFAULT now(),
    error_message text,
    schedule_key character varying(80)
);


ALTER TABLE public.notification_log OWNER TO root;

--
-- TOC entry 226 (class 1259 OID 16913)
-- Name: notification_rule; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.notification_rule (
    rule_id uuid NOT NULL,
    user_id uuid NOT NULL,
    ref_type character varying(30) NOT NULL,
    ref_id character varying(64),
    title character varying(120) NOT NULL,
    body_template character varying(500) NOT NULL,
    remind_days_before integer DEFAULT 3,
    time_of_day time without time zone DEFAULT '09:00:00'::time without time zone,
    timezone character varying(64) DEFAULT 'Asia/Bangkok'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.notification_rule OWNER TO root;

--
-- TOC entry 227 (class 1259 OID 16924)
-- Name: receiver_mappings; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.receiver_mappings (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone,
    receiver_name character varying(255) NOT NULL,
    user_id uuid NOT NULL,
    category_id integer,
    debt_id uuid
);


ALTER TABLE public.receiver_mappings OWNER TO root;

--
-- TOC entry 228 (class 1259 OID 16927)
-- Name: receiver_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.receiver_mappings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.receiver_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 16928)
-- Name: repayment_history_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.repayment_history_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.repayment_history_seq OWNER TO root;

--
-- TOC entry 230 (class 1259 OID 16929)
-- Name: repayment_plan; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.repayment_plan (
    plan_id uuid NOT NULL,
    user_id uuid,
    monthly_budget numeric(38,2),
    created_at timestamp without time zone,
    strategy_id uuid,
    strategy character varying(255)
);


ALTER TABLE public.repayment_plan OWNER TO root;

--
-- TOC entry 231 (class 1259 OID 16932)
-- Name: repayment_plan_result; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.repayment_plan_result (
    plan_id uuid,
    month_no integer,
    total_payment double precision,
    remaining_debt double precision,
    plan_result_id uuid NOT NULL
);


ALTER TABLE public.repayment_plan_result OWNER TO root;

--
-- TOC entry 232 (class 1259 OID 16935)
-- Name: repayment_strategy; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.repayment_strategy (
    strategy_id uuid NOT NULL,
    strategy_name character varying(50),
    description character varying(1000),
    is_active boolean,
    created_at timestamp without time zone,
    tags character varying(50)[]
);


ALTER TABLE public.repayment_strategy OWNER TO root;

--
-- TOC entry 233 (class 1259 OID 16940)
-- Name: repayment_type; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.repayment_type (
    type_id integer NOT NULL,
    type_name character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.repayment_type OWNER TO root;

--
-- TOC entry 234 (class 1259 OID 16945)
-- Name: repayment_type_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.repayment_type_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.repayment_type_seq OWNER TO root;

--
-- TOC entry 235 (class 1259 OID 16946)
-- Name: repayment_type_type_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.repayment_type_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.repayment_type_type_id_seq OWNER TO root;

--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 235
-- Name: repayment_type_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.repayment_type_type_id_seq OWNED BY public.repayment_type.type_id;


--
-- TOC entry 236 (class 1259 OID 16947)
-- Name: slips; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.slips (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    sender_bank character varying(255),
    receiver_name character varying(255),
    amount numeric(15,2),
    transfer_date timestamp without time zone,
    memo text,
    image_path character varying(500) NOT NULL,
    qr_data text,
    raw_texts jsonb,
    status character varying(20) DEFAULT 'processed'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.slips OWNER TO root;

--
-- TOC entry 237 (class 1259 OID 16954)
-- Name: slips_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.slips_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slips_id_seq OWNER TO root;

--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 237
-- Name: slips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.slips_id_seq OWNED BY public.slips.id;


--
-- TOC entry 238 (class 1259 OID 16955)
-- Name: transactions; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.transactions (
    transaction_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    category_id integer NOT NULL,
    amount double precision NOT NULL,
    transaction_date timestamp(6) without time zone NOT NULL,
    description character varying(128),
    budget_id uuid,
    image_path character varying(500),
    receiver_name character varying(255),
    sender_bank character varying(255),
    slip_id bigint
);


ALTER TABLE public.transactions OWNER TO root;

--
-- TOC entry 239 (class 1259 OID 16961)
-- Name: user_device; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.user_device (
    device_id uuid NOT NULL,
    user_id uuid NOT NULL,
    fcm_token text NOT NULL,
    platform character varying(20),
    device_name character varying(120),
    is_active boolean DEFAULT true,
    last_seen timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    "deviceKey" character varying(64),
    device_key character varying(64) NOT NULL
);


ALTER TABLE public.user_device OWNER TO root;

--
-- TOC entry 240 (class 1259 OID 16969)
-- Name: user_setting; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.user_setting (
    user_id uuid NOT NULL,
    notifications_enabled boolean DEFAULT true,
    push_enabled boolean DEFAULT true,
    default_remind_days_before integer DEFAULT 3,
    default_notify_time time without time zone DEFAULT '09:00:00'::time without time zone,
    timezone character varying(64) DEFAULT 'Asia/Bangkok'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    current_profession character varying(255),
    skills character varying(255)
);


ALTER TABLE public.user_setting OWNER TO root;

--
-- TOC entry 241 (class 1259 OID 16981)
-- Name: users; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(255),
    password_hash character varying(255),
    dob timestamp(6) without time zone,
    email character varying(255),
    email_confirm boolean,
    refresh_token character varying(255),
    created_at timestamp(6) without time zone,
    is_active boolean,
    updated_at timestamp(6) without time zone
);


ALTER TABLE public.users OWNER TO root;

--
-- TOC entry 3350 (class 2604 OID 16987)
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- TOC entry 3357 (class 2604 OID 16988)
-- Name: debt_type type_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_type ALTER COLUMN type_id SET DEFAULT nextval('public.debt_type_type_id_seq'::regclass);


--
-- TOC entry 3365 (class 2604 OID 16989)
-- Name: repayment_type type_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_type ALTER COLUMN type_id SET DEFAULT nextval('public.repayment_type_type_id_seq'::regclass);


--
-- TOC entry 3366 (class 2604 OID 16990)
-- Name: slips id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.slips ALTER COLUMN id SET DEFAULT nextval('public.slips_id_seq'::regclass);


--
-- TOC entry 3585 (class 0 OID 16867)
-- Dependencies: 214
-- Data for Name: budget_per_month; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.budget_per_month VALUES ('220ecd8f-f942-43bd-9860-afe38abda8f4', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 0, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('0726f1fe-e807-44e9-8e19-dbf776d994c9', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('170e08ff-0504-424a-9290-b751f797785d', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('d143619c-c573-45ca-860c-389170a34c69', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', '0f43a469-1931-4108-8d76-81f5b8604168', 100, 5000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('e8097651-1d9d-45dc-97c7-2c403cdc2178', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('6a74c673-886c-4e65-8c96-0635bf0f6eb9', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 5055, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('af8396f9-1327-4260-9aab-c03defcf708d', '0f43a469-1931-4108-8d76-81f5b8604168', 109, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 2192, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 10080, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('f4f4ef71-f670-4d6a-a346-aebee4a0bf46', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 0, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('ee2da718-093f-4923-9a3a-f518258d7c69', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('d6aca775-d66f-4b76-be8f-7817d9d0ab7e', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('632c5a43-6c4b-40bb-bf44-d1bbe30302ee', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('712107a2-cd0a-4757-9f6a-465efc405e59', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('82fd7bca-8b99-4047-98a8-9dc56227e50b', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('e23f3f14-877f-40e1-9a87-7f993710a762', '9db8aa73-7870-4481-a109-6430ca921dd5', 300, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('18558519-c4bc-42f5-a19a-41b7d1f72779', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('89d5ecb1-68e9-491d-a8aa-8372c4da2893', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('919e89a9-dabb-4cc1-98b3-4a8ea4e4080b', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('add863c4-7e7f-4b86-b6d4-30e46706780a', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 0, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('bfc856fa-f166-4695-9075-c8f1c736216c', '9db8aa73-7870-4481-a109-6430ca921dd5', 181, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ce70c43d-46fa-4f75-b3d1-dcb3a7a6ad5a', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('d253a905-c644-4e8d-b089-6ed551cd0ea4', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 10000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 1500, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('51b65c1c-58ad-482e-a64b-efc997301ba0', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('9443f731-0fcb-469a-831e-004e137b22fd', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('b2060743-1b82-41b0-ae7b-f2b7db8c1374', '9db8aa73-7870-4481-a109-6430ca921dd5', 5000, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('3d1d3545-9301-4554-90d0-e64303bb0f8a', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('b922d4cc-bfff-4e0d-848e-42c9d5ae6a8d', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 2000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('906a6215-7176-4053-9770-1a75578d4c69', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('308e10b0-d500-49f0-a921-e3c8bd977c0c', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 0, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('0064a21b-9e1e-4ce2-86ba-e946e8e2c96a', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 5000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('d89d882d-7e13-49e9-bc38-402edc4c8b47', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('489c58d1-5021-41df-b80f-8d3abdef0395', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('85582c9e-d6a9-417e-9532-7af719224958', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('fa641ada-29bd-48d2-9dc7-c154134d592c', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('6497787f-abe0-4cdd-82c6-d657566ed4ef', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('7c4d4d80-0b55-484d-a1d5-83964bd9ed2c', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('04bab63d-675b-4778-a7a1-fc4087bce45b', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ee2f8e4d-e266-4968-9eec-ec2b1e814e79', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('0d5001a7-6af7-489d-80ba-a884e4836c13', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5cb25865-2e2c-4526-9e0c-f1ffad8da69b', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('f91be015-9c62-41ff-99ac-5edf2e4c08bf', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('b7e522ab-c8df-4f0c-b03b-73ee58fc08ec', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('8e27acaa-555b-4c55-8d73-8be31e660a61', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('60e0b245-febe-4b4f-9a78-7fe90353ee4f', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('e46c1399-418b-440e-90e1-d8244ef5c74d', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('d97beb12-390e-4968-aea9-e048680db24b', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('b313a1b8-e6e8-48ac-b64b-47a36074142a', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('55ac50d8-5fe0-4f78-922e-493354230156', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('78bab02c-a830-4ef3-af99-d76b1a6c9dff', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ba7dc91d-90a5-4d46-8a85-e3e8f6ecc61b', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('46d0fb34-593e-48af-91ca-6c7188913532', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('7cb75f90-0e37-4658-8b6a-a79022bf7a92', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('31f689d3-1ec7-44b7-97cc-789c70511f3a', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('4e0e04b0-06fe-4fdc-98e9-9ea9e0f9d360', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('49812e8a-fe4e-4f99-a581-f65e322d9afd', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('c67eedf3-988b-4259-8d0e-229cd90de9f2', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('12b25db3-7301-4503-b316-7634f2a2745d', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 1500, 10000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('23c25122-13c5-45c4-b9fd-48997b4096bf', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', -121, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('e0325643-db82-40c0-8702-ed18a3b6e41c', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('dcf18b34-bb0f-4aeb-99d6-b4f4b1824bd1', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5f4ce6e2-1d60-4c86-862f-0c15275187b3', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('592addb3-574c-44dd-bf86-b89f4b2ba5ed', '0f43a469-1931-4108-8d76-81f5b8604168', 389, 1000, 2, 2026);
INSERT INTO public.budget_per_month VALUES ('6c71a9b9-2a2f-4cfa-bf11-4e490e0b11de', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('4b379c64-10ae-4b20-9daf-02bf1649ddf4', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('db002fc9-9413-4cca-b4d6-b59302962d16', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('bfe7bcfc-2568-438b-bd8c-fa1234e25375', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('c3f555e9-048c-4ca7-bd03-2f6388713ec0', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('967740e5-61a7-4fe9-b395-9b38db52f285', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('bbbc6211-26c9-46bf-a736-18c08d037b2e', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('d2d4f062-bbf2-4c7c-a008-b5b06e473192', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('4c81cf10-f401-4604-988d-b438b5bb960e', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5212cce3-4a64-4876-8864-f48963f1fba8', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5a7911b6-a0a4-41c4-a21a-8d8490578131', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('7293fa9f-f8c8-45f9-ad34-07d6af894b6e', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('3d0f6504-bf19-4755-9c32-efaf86026a81', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('624799db-3d38-4d64-bf94-26eebcc42a56', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ec0deea4-c599-46e4-b191-31f7dda4b60f', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('42b2a75e-1713-4f95-b0e3-4ae5938eae05', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('c3e2b958-2a95-417c-bd33-3743f41168c2', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ebd9e3ce-b909-4f53-94d1-ec6068792e71', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('fe04b545-3119-42c8-8ee7-05e2abcf3a21', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('82d69f20-7e66-459c-86dd-f5a947c8d264', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('35fbb865-b3df-46e8-8cb4-37794c819883', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5ed6ce7f-3402-4d59-9713-a3899bf88393', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('f9e8b144-eb0c-4764-b877-968bdf2428d9', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 3, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('8ff337c7-c144-44c2-a480-b242838ec694', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('2cbc435f-1c04-487e-b22f-434bdb73e022', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5a703493-99ad-4881-bc98-a773d4ed092e', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('67073442-ff11-486f-a648-729a933152e7', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('cd365bbe-0757-412a-8fac-1f0e5eabe7bd', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('751fee63-db79-48f3-9177-fb4ce1368f47', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 1500, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('d4cd52d6-77e0-4689-912d-107bd6a14dc7', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('31754809-5703-4f52-9b48-f58b6da5a0cd', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 5000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('97e1a8a2-194c-4393-a68d-ac12f7bb73cc', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('c1276baf-5181-4b09-8f4e-8fbc8cdb2838', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('321f5b0c-b578-45bc-b305-49e2d8c21818', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('2324c3fd-e342-49c7-a8f0-b4f95a1c88cc', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('e1cbe40a-b3b7-4ae5-832f-9fb14b5520d4', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 5000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('74c624f3-5986-487a-90bd-b1c003a8e802', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('0437194d-575e-4d28-9865-d484295dab81', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('9a7fa226-47eb-417b-9cdc-f9890c1fb50b', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('a236f5f1-bae9-4908-825b-380cac9021d2', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 2000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('bc35598e-4547-4174-9e60-fa924e6bdba7', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('cf2d8cce-57bb-48c9-8ae0-a2fa3e7e9049', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('b231a80d-b4ef-41e2-b68a-79716c0620e3', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('9726afc4-153f-4b8f-8022-b4d40bff1bbd', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('67d4b7e7-16e6-4f11-b76a-533a5ba7e215', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('a11b354c-c9a1-4c5f-93d7-e4b7c4a0c1c2', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('d5de2b1b-6266-4942-9616-cfc14e166039', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('bef45294-e302-40bb-ad27-0489bbe15d81', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('470b5791-f2e4-456c-8969-aecc44f9e886', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('98489f27-52fc-4361-8e8d-b0fd4d0f01ac', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('37f9445d-ef91-4f8a-8bc9-7226803780e2', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('b08626fb-084f-4b56-9bc9-d8f9c523535a', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('bcf6ea15-b2b6-4795-82b4-797878101022', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('531408ca-5248-4647-9f28-12002cedb973', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('672d6009-05aa-433a-b56f-944ed7264607', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5be57cef-2cac-4156-878e-14e9206092b1', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('a2e905ff-dc68-485f-96e7-6fcd37ac57c6', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('0dab081d-64c4-40e2-bafb-522dd60539eb', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('90b2e397-cc69-49ba-b641-6d91a77fc0fb', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('d0edfd78-1ae9-4dd2-8823-9ce41254906a', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('75cac2bc-e0be-40d0-9d5c-9ce5428eeb17', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('6b86458c-1775-419c-ae7f-32104d86deff', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('e8945a1f-c22f-47c8-9619-20359454cef6', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('435aeb1d-b103-408f-83b7-5f754f569e4a', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('095c992d-069f-4a8a-9868-5c8d99d1618c', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('b127809a-5189-4e54-8e8c-ecb51e544209', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('aa6ad23a-9770-4555-bf43-bae17aa6ffb4', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('13503f5f-e300-426b-81cf-1abd6a7ddefa', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('f8a7875f-0fa3-434c-b8a7-48a99deee152', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('2694df67-9468-4d1d-ad54-67ef102b8bb7', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('e09b964f-9b5d-4c10-883c-44a5c60739ee', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('2acd87bd-0e5f-4964-a88b-d32f3ea2af1c', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('4e291954-53f6-4d62-872c-afadac662ce5', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('7a1c8552-fcd4-4fc6-9dda-08c6e81fee17', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('879f0abc-7459-4921-850c-6ffdb71b3da4', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d8f9d06e-3b39-466e-95ae-09e29aa11ff1', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('0b48feea-fb9b-4384-ae34-7f3888c702df', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('563e7954-9966-4db5-b2b4-af9831101325', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('513448b8-05d6-433a-ad2e-bdd3cfe48b8d', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5d0b6a7e-e539-4868-ae27-107f2ef9b92e', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('78a42b46-2c36-4ce0-aaf9-fb3b3687cbf6', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('94f0527b-27b6-4cab-81ff-16adb96de367', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('048db6dd-00b8-4929-862d-fd611fd0db5d', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('cfd5bbae-bb1f-4310-bcff-1979b8087164', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('6a753a33-54e7-44d5-8712-5eec3168d066', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('6691193b-6c93-4da7-98c9-b57b9f626fe2', 'f69c0230-b36a-4029-b128-d005743a0efb', 3, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ad91023c-d8c7-461f-8965-a1f593bdd373', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('d99da596-bf40-4994-afe9-9d95d15470ad', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 0, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('527cbbee-609b-400d-95a0-a3d52e2775db', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('22161caa-d399-4578-9dd3-01a0ec523e77', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('0818bdc2-423e-461b-b3b7-5cec3e4e3a11', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ad862fdc-59f1-4372-95b0-ad3adb430225', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('c7f5c20e-c2c5-4d6d-8ed7-808d20ba685d', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('258ab037-555c-401d-bb37-4885a8d98cdf', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('6c96337e-5b6b-4570-81e4-2dc3ff32b0cc', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('ed4fc326-1982-4944-919f-f2e67db55476', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('5b404c70-4098-49f8-98a6-6a90d965187e', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('07dab662-676a-4fa0-9414-08f7e68889c9', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('35982d05-a117-426d-aa98-b5a513333d7e', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('5cfba100-c6de-417f-b902-761f6d4136c1', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('6c76aafe-8cf2-4175-b64e-3e794ced516f', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('53e8e7b2-ee7d-445e-aa2f-245e513c15a2', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('e6d9dddd-a36c-428c-8c95-fcb09be16d7e', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('9bc83218-cf08-43eb-894e-c7950aacdfdb', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('41d2981e-e566-435b-9404-178823294aee', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('ed114ff6-5b6a-498e-81a5-c867a60e835d', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('6bd855bf-8e24-4894-84a6-5b48174d9cdf', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('6bdf979c-b053-4ede-8559-f67c5f8d01eb', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('98a0dba3-63bd-4ad2-8420-a52e34c1cdfe', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 3, 2026);
INSERT INTO public.budget_per_month VALUES ('4e6d1890-5f18-419c-bd96-65086994ce7f', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('a9e66568-963a-4f3a-9b48-6850e586347e', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('79008752-114c-4994-b4fe-e73c6f05ceed', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('0ab44a09-e997-410a-9f88-7878d95870e0', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('ee899d01-ae2d-4c18-bb2c-4791f95220e6', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('55b76a37-a4d5-466d-afa3-34c0b37df0cf', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d19fc84c-097d-41a7-ba5a-601ee3485cf5', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('78b2f2a0-814f-4be4-aa85-0cd14510ef41', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('b7069ece-4c9a-4e0e-8cc0-9ebecd774bbc', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('decdd07e-ffae-4946-a1db-0ef309a5b75f', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('631667ab-9666-4c3f-a4c2-4036db4ab544', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('142a3f09-fec8-4189-979b-7d549a9ae6e0', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('00d7d97b-d126-4817-b983-c0bba89e0abc', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('9f56a114-662f-45f8-9fd6-fc20dafbb3ba', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('f919a525-27e6-4cdb-bf07-035e91cdd42e', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('0c603864-536f-4193-8ff8-2b53c86ceb1f', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('0bc053b9-e777-4b09-b675-cf7de920a99a', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('32e8fa6e-9fee-458b-850a-2eaac0696b71', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('b954cb7c-8ad8-47cd-b684-c068365679b4', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('23327571-0363-4c3a-a0c3-bdd102313f02', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('c7ff30d6-7175-4f51-977e-e3a1b566081a', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('89c4692f-6c9e-4105-9b86-08b00f57c7c6', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('c2ae70ac-f9fc-4ea4-8a5b-1fbd38dc1a88', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('4130e279-3081-419d-adb1-8bb7b88d9634', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('25cd46d7-2c2a-4110-abfa-5d282915ed4f', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('70e0aa11-75b5-4d66-b2c8-70a60f8fcac5', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('e7434137-4033-41da-9db7-32283098ff21', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('a6415d21-18d6-4cce-b462-1027bbb3c271', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('4b3278a9-07e3-46e8-8112-64f70bc25a97', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('caef5f9d-2b75-4417-b4eb-f0ef6ea55c6e', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('ade1e435-ac2f-4c8d-9142-69faf7af1d91', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('99682701-b1cd-4bd5-91fb-fcb9e5a44a3d', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 5000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('865c6eb6-ed71-45d6-be73-ba99715adf68', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('96702975-2bf1-4238-a3e1-b5be3fbd6cd7', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('b5034e12-7c04-4060-9b8b-483d5443b169', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('f3183552-1538-4dac-8c88-edd7397b4435', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 2000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('aedfef47-764b-4b82-afad-d08a357ef487', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('64141bf7-c3ed-44ec-8c6b-47cdb55e3fe1', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d8ea9d83-7d0d-40c6-9de0-b62324c8f5a7', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('9b38f512-2fca-40fc-b2c1-1e61388ebec2', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('038ea1fa-704d-4df4-9672-4850ae95b8cf', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('57a468db-a109-4992-a020-aa1f6ab1fc33', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('95ca79cd-5faf-4ed7-9839-def98d604e13', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('125b7caf-7d39-459f-887e-fd24e77a6ff8', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 10000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('106a2d0d-4cc9-475c-94c4-5c79178f6227', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d6a6fa0e-82d5-4494-8150-a433dd4d76c2', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('9bd7cf89-e08b-46e3-b6a5-fc892cd945da', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('9391eb53-9914-483b-b9c9-2c3f0ee59ee1', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('34b4d458-0212-4f2a-82ae-8457d1a635ae', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 10000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('929cf85d-5e6b-4dc3-ba44-04d17293ac09', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('3d4add52-2234-44da-9741-79ae8f255d9a', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('8b14370a-2c37-45af-a2a9-e30f52df4247', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('5e662f57-1d42-4c43-a7c5-8c2b00141800', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('87525925-2014-43af-8462-810c1e6ff51e', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('92657017-ca1a-4089-a236-3f1e85ff93cf', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('5fe831cb-f716-4c3a-a3cc-b41d50fa0871', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('bec31457-e119-43a4-b376-b99ea37b7fac', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('7cb5f72a-fe56-458b-ac3b-10c00dcd7519', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('2a2a4e06-d7b4-4671-a4e7-d1e3cc6723f8', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('145d5d56-4ee5-4649-a6c7-e2d7dade0fcb', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('1632b1f8-3d06-4e78-89ff-74342e72b280', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('7d244796-9f9b-4cf7-b28b-9d0d79db054c', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('fc471f3e-3f77-4fa4-bbd5-a922f2509d20', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('44707f7a-e2f7-4b9e-9ec7-006e71505236', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('aa722298-98fc-4a8a-a528-fdf76e340ed5', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('af001877-2a81-4bea-9dfa-8c605875505e', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('f5376de2-95d2-4762-b001-fd7af3e6ee50', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('47a7974c-d8f8-4ecc-8961-80ef17abfece', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('c02f15f5-9c4c-40a5-8c79-fd5e354edf97', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('cde2c53e-87c7-493b-b340-eb62f6f5a91f', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('3c5a9df7-72a0-4edb-9f4f-67138d9d6f3d', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('6ebcda68-7837-4e57-9ed3-edc0fe3faf3b', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('65b3b609-a589-411e-b2ea-3359bf3b4340', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('3221e623-8e7d-4d37-94d3-7eaf85276c64', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('40542529-3bc6-4e18-a1bb-6168c2928da4', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('34898378-79e2-4b88-95b9-ceeeb70239f4', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('2a39f230-5a95-467f-a8cc-5ee6d55cb1ef', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d23711df-532f-45a6-8653-68ef439def4c', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('ace3b330-b9dc-485c-86ae-97add0861738', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('02005237-3793-492d-8330-2d1f00ac2f74', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d1d7537e-3ac7-4219-b172-ae2bc3f34b9f', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('38a5c04a-c989-4e46-962d-856d47e1141f', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('b097b10e-8060-40f2-9360-55119b6ad2d1', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('984380a3-020e-4786-b97e-9fd2f3c65f61', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('7013cdd6-d133-4abe-be67-b264c7e6df22', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('af07bff3-b79b-4a73-8a0a-4f749bab0acd', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('68e733fe-598f-4be4-9173-e2df209aa718', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('be6713ef-30a5-4ae7-b1e7-b38a31d28f2d', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('8f0fd781-584a-4ab7-8b09-c5a6c1680470', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('c0d4e646-8239-48fa-9ab0-76d41d141376', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('afebafcf-0467-4c8b-950d-44e4801eb57b', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('96f8589a-9322-4676-b6cb-6feca4df5ed0', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('c81eeada-9ff0-4ea6-bfaf-377ef2012d39', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('ae2e5c97-6512-4717-af42-dda28cf182d3', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('21867a2d-4661-4824-909c-49b7538925a0', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('687a7fb9-07ba-4644-9eac-4038edbf4eff', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('0993c024-1248-42aa-954b-1c718dd955c3', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('c8618df1-8c4a-46f5-82e6-7f1591646e91', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('466c828a-c5de-4cb8-ac43-0ace578ef9dc', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('c92a7ca8-0fee-4e45-8466-f4e3bd53565a', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('e5a7fda5-2a50-45fd-8ede-197c30c01d85', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('af421d4c-6660-461b-92b6-5d52db4231cb', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('5efa9d87-7884-481a-9dd7-587a4d55b10a', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('1fa339db-d5c2-49c3-aee0-4e04682811d5', '9db8aa73-7870-4481-a109-6430ca921dd5', 15000, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('9b64e5eb-b65b-4a4c-8d25-aa4583b46002', '9db8aa73-7870-4481-a109-6430ca921dd5', 280, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('0e0207bb-3c00-417b-b898-8b6df3a1e48e', '9db8aa73-7870-4481-a109-6430ca921dd5', 120, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('6ac87944-e7ce-420a-a681-e5c411378576', '0f43a469-1931-4108-8d76-81f5b8604168', 350, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('51e852e1-7730-48af-ba45-c034060cbbc7', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('80697d4a-b27a-42bc-aa3a-08d8f69a3ca8', '0f43a469-1931-4108-8d76-81f5b8604168', 20, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d9a93a03-5013-4a3e-ae0f-71d40a4c8bee', '0f43a469-1931-4108-8d76-81f5b8604168', 120, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('e8125110-6132-49af-a736-e8523b696d04', '0f43a469-1931-4108-8d76-81f5b8604168', 20, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('2611e154-68bd-49f1-a87f-d7c34d73826c', '0f43a469-1931-4108-8d76-81f5b8604168', 356, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('f6ebc8bb-e379-4ad5-8142-ae6eb60a1c97', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('494b4e56-7ccd-4f07-a41c-beee74ba58db', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('0f0bc8b3-3fba-4ec6-838c-80f343a10713', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('430eed72-1af3-4fe3-9e9e-33e0147b2334', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 0, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('f3bb5207-ff44-4227-b4e2-dcf35e37cb94', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('6ba18fef-777e-408b-a0de-f41f5bcbf0cb', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('eaa5af2a-e69e-4ec5-b2c8-16bcc52229fa', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('2f461f94-3452-4af9-94ce-fad6b17e9301', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('a984b745-bcfb-49b0-9e08-004cc15c26a5', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('3269149f-a7ce-43ce-800b-13bc3e85edca', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('d255e4a2-b65a-4245-8233-62a8282c8feb', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('cd51da5c-85a3-4cce-9fe5-ca7bb0e34f27', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('5495058f-18bc-4aff-93f2-4af9052ec7a7', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('6195733b-d593-43ec-8703-bc2c7a7243a8', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('e7bb2c20-011d-4070-9e02-a1008d8341a8', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('af34d6fb-c9ac-4f77-8be6-4c5b4bced8dc', '9db8aa73-7870-4481-a109-6430ca921dd5', 150, 1000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('81244a1c-464c-4ee7-bcec-834cd30cce1a', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('f7c700cc-929c-4681-9203-4fd89edc50ee', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('c7af5ee3-cebf-4257-98ad-c36c9ca280b8', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b4bf7339-0f58-4ad7-bdec-e5cbc76cf9c0', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('7358ec4b-803c-4321-b198-49febcea4fe7', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b8fb2bd1-5f9f-4f63-8917-a889086c179a', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('ced5885b-78a7-4caf-992b-13f0f8c5299b', '26da5e42-b707-44fb-94a0-34121e8ce20f', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('6e7ccb6c-9eba-4934-adc5-655a9286ac2a', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('9a03afb4-9376-4ef8-94f5-8ae4cb9ace71', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('f8360f75-164e-438f-8f64-cc267c704449', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('29034dac-0ac3-47ea-a52a-d2b6f652a57c', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1dc71ba2-c10a-4b95-bc80-f956ff3be3f6', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('2627f367-f5e1-4478-ad4b-2b0145475890', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('9efb7e75-0ccd-4eca-a91c-8d502998cbf3', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('d495d681-7b30-4e88-8d0c-8d615575bfe4', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('3b074fe2-5111-4169-9d98-1f129e5fea95', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('482d6b88-4c20-4666-a5e4-41eb68cb74ca', '1141aa56-463c-40e8-8f86-73e18095541c', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b8c6e92d-5b76-42c5-92a5-8cc7130be181', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('d8887c69-95bb-4cc2-8aad-698d273c0617', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b64e781d-78d7-4983-86bf-8ca7a8ecfef0', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('2179cbd8-0130-471f-8bb3-6871307e48b5', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('6bb4d0ef-33d3-474f-b224-66d932c7f7a6', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('4366aea2-8d20-4840-a4c5-e6eef2458225', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('680837eb-cdb0-4346-9a93-8ff91d1e28a2', '0f43a469-1931-4108-8d76-81f5b8604168', 490, 5000, 4, 2026);
INSERT INTO public.budget_per_month VALUES ('269d042c-5859-4cea-bfcf-ab4befc01e93', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('8abacd55-2c52-4af3-838e-ae8054cfe361', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('0355c225-37bf-4061-b938-25dc1c188a54', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('bf19b4a9-dad3-449d-acae-47b59718ab60', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('4cb9fb10-1633-41e7-8b10-05b2d00fcfd0', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('ee42acf7-65ce-4311-89a6-cd60d43fae20', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('33a6e87a-7f50-4043-ba58-b9ce56d64786', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('09bbc44c-fb39-4ff3-9eb1-f28ee33acf2e', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a9857aed-bc54-4a83-bece-d01ea64930bb', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a2305cd8-cd2a-4bd0-8eac-4c8a9c25debe', '4d22eeac-ddb7-4499-88af-806d3340d8fd', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1f2edf29-2194-4c5c-9b61-17710d5255e0', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('5417487f-8044-4be0-bbd8-aa0e858d64f5', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('e5c39575-2a2c-4a52-b86a-caecfd796e63', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('f8825579-e140-4455-ad0e-d2ae1c129033', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('eaa7e960-9a3d-42fa-ab90-dccd4c07e277', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b053e5f2-1d40-41db-8ea3-d300bd93f441', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('c0824424-d176-4949-96fd-c51acf998754', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('2aa9675d-cd52-4941-aa39-23c5bce4d721', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('3c3d5e50-5e6e-4511-8d50-00d224193046', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1c2874ad-bb7d-4b8e-9441-5a5251033c6f', '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('fa6cdfd0-a10c-4894-8a03-20fd1f654dc3', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('8dd50f34-1529-43db-98b4-bc870774b051', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('781a4032-710f-4a86-b72d-a59944329192', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('8af73f88-e67a-40ff-b9d4-0a093e03a217', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('888d75de-cf39-407d-b2df-ed78cecaa79c', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('8b36b60c-6d5e-42e6-bbbd-06b87fdabb88', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('54aa07db-8c9e-494a-addb-ccaf5f70a404', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('8f57746d-640b-4633-935f-3a410c2f9a75', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('30aacf0f-7d8a-47ed-b903-7e71f168b44e', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('4297c4af-119c-4b38-b852-152006f0c39e', '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('6fc1b2e6-6c36-476a-9694-ec912add101d', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('63266ef2-f83d-4f3b-b987-7dded24253e5', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('42bf43f8-856d-40db-99a6-955fbba955af', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('cc1aa9be-539e-4fe5-90a6-a6b635c7c569', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('cd63f14b-9a47-4abf-84eb-e46154b75371', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('6223c467-4d6f-42b0-a4eb-03682ed3d7d2', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('8a93ba2d-2ee1-4eb7-8c79-96ef0eaa947e', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('9f5091bb-3ea1-479e-b041-8b26ad858279', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a754fd04-23b9-4758-b8ab-1538fadcc6fc', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('7bd07565-8b87-45ad-9fc1-e675c2f2afe9', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('cf6f73d8-b049-489f-b94f-6a0b7fd801d6', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('11a189ab-5a72-48a7-ac8c-8bb00a0bf79e', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('cbec0f99-e798-4765-be51-0784be957b96', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b98c7a71-bf18-4000-acb3-4f1101fb3b6d', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('f73d140b-384e-454f-9711-fd749961ff36', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1695ce27-7258-4b3c-9b97-7ec462c9cb32', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a9283667-d107-48dd-86a1-5ba888193493', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('238db314-3c71-4797-87d6-b6997e8c0e46', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('35b57b55-fd08-4ba8-862b-e117e896d2e6', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('45d21a31-f785-4200-9136-f0a061f0313e', 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a01ff4ae-4ac9-4abb-ab42-cc27cf42454a', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('85fb9a5a-d19b-47ef-9a3c-b34de845d8d4', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('983175ec-92e0-4a3d-b728-f9638f091e4c', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('e203bb28-2a7a-48e6-ab84-ca866be12d50', '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('0ad2f8fe-42fb-4022-ad19-7c8d17b3edf9', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a0f3404c-e1a2-4305-bd31-5e8584b5c5ec', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('2d409fe9-0dc1-40cd-a6aa-e19f41c67fa7', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('15da8d32-d275-49f1-9c80-d51fae2f74a3', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('038f4e4f-d88c-4396-b0f7-69e03cea6b79', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('45986df9-82f7-4bb3-8976-80cafddb620d', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a1995576-6ec6-4945-93d3-6ff8b717bd1a', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('7b150291-5535-486a-943f-f75d57b457bc', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1b4193c7-d429-4f3f-9f16-0436a289f580', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a4cad155-cafd-4fa4-938f-2707be89eb45', '7cc650c8-16c6-4937-8347-199ffb28f650', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b1cb32b8-c38f-48be-9737-00b3627cd076', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('2df5c2e0-6d39-441c-b8a7-6bbf9db16e89', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('5879996c-33ae-4722-ad2c-281eb40e7ee3', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('4905926f-91a3-4ebc-a780-20454b364bc5', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('76bd7009-e11a-4a6c-a013-c9b059a65946', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1264d33d-7af2-4832-a067-3e4adb088bc0', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b270d7da-92bb-4b95-b1f8-83ec1f2effee', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('f0b13e60-ecb0-44b3-8e2f-537dde60cbe8', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('648bd5f5-1af5-47d5-83d4-32e5e319f6a8', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('548552b0-5e6e-4afc-8e06-a5f26b1062d9', '937c2768-1626-4167-8e9c-fcfc2358e3f4', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('fff011c0-bfcc-4c49-9720-0440f61cd019', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('935faa1f-0ce0-449d-a8c4-9ef9fd37c654', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('cc722ba5-7369-4778-bebc-6ed712230b41', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('61d9a0ab-698b-474f-a11d-7bf70645efe1', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('cee129c7-ecc3-4dd4-bb2a-9fb31d1d30ab', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 10000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('ddf0cd70-fad1-40a9-9db6-beee75002395', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1651eca7-c2cb-4440-80d3-81b66f220ec9', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('fed6c39b-1481-4938-930a-70f2571cb526', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('86c1940a-f4e5-4a70-972f-0ee99a6b77b0', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('e4d2c20d-1a65-4986-b561-2ce9467b16a0', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0, 10000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('d2bb377a-aee2-4abd-b16d-49e04956b5ef', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('1902b23c-e881-4afa-8791-47040786240e', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a165cf38-1718-4ed3-af63-62d504ee7e5a', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('67b14b9b-63d5-4b87-9150-685b28a68b83', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('58a56f70-c915-446f-a37f-1a8110bb20b2', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('9aff73f2-1943-4849-a62a-2e62e4052547', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('cefba24b-23c8-4904-b526-25d863b3a2bc', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('d3290c5c-0188-4817-8c64-f289de95dc7e', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('79a3fa44-c590-40c7-b2ea-eae71f519576', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('528f33f2-09f2-4ffe-a64c-856df0ab045d', '9db8aa73-7870-4481-a109-6430ca921dd5', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('ed1ec8bb-8bcd-4164-a28e-8ae026113663', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('c65bf0d7-4daf-4618-9d2c-15213bbec5aa', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a7b314ad-aab2-4447-b30b-7534d223c473', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 5000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('d98b70a0-9feb-4b6e-b38d-b6197c11e506', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('0ddb87dc-6327-4335-8f2a-2b823ff4e266', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('6f70b85c-3699-4e01-adcf-e00ee77b9dfd', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('6c2b76ad-171f-42c5-a3ec-dc7d152802e4', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 2000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('048ce1c6-04ed-4c6c-a9cf-321fc5d82451', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('8fc26b05-0109-47b9-bdf3-6eab90852286', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('a2be1c73-f0e1-4d24-afca-a7a0d25149a2', 'f69c0230-b36a-4029-b128-d005743a0efb', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('4593e2ad-754f-4c6a-b437-e1e69985ba25', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('be210da0-032b-4f78-8686-fa02c0096e19', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('52bdcbb5-4231-49af-94ee-8f92e81f8fca', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('84ef4dbb-a4c0-4b5e-b7d6-79ea228936f7', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('b63b65ff-656b-4492-b55d-730d4ab9ffc4', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('4c28c838-f80b-4d5a-9a91-f2e2dc141021', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('f3f1c127-59c9-460f-aacd-769c3098365a', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('2871a586-f004-46cc-b761-37e3675e0ae2', '0f43a469-1931-4108-8d76-81f5b8604168', 0, 1000, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('32451362-0e1a-4177-a9dc-4d896225a885', '0f43a469-1931-4108-8d76-81f5b8604168', 80000, 0, 5, 2026);
INSERT INTO public.budget_per_month VALUES ('933ad0ce-adf5-485d-9c12-9d8b87470090', '0f43a469-1931-4108-8d76-81f5b8604168', 30, 5000, 5, 2026);


--
-- TOC entry 3586 (class 0 OID 16871)
-- Dependencies: 215
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.categories VALUES (336, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Salary', 'Income', '1f2edf29-2194-4c5c-9b61-17710d5255e0');
INSERT INTO public.categories VALUES (337, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Extra Income', 'Income', '5417487f-8044-4be0-bbd8-aa0e858d64f5');
INSERT INTO public.categories VALUES (338, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Food', 'Expense', 'e5c39575-2a2c-4a52-b86a-caecfd796e63');
INSERT INTO public.categories VALUES (339, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Transport', 'Expense', 'f8825579-e140-4455-ad0e-d2ae1c129033');
INSERT INTO public.categories VALUES (340, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Health', 'Expense', 'eaa7e960-9a3d-42fa-ab90-dccd4c07e277');
INSERT INTO public.categories VALUES (341, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Shopping', 'Expense', 'b053e5f2-1d40-41db-8ea3-d300bd93f441');
INSERT INTO public.categories VALUES (342, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Bills', 'Expense', 'c0824424-d176-4949-96fd-c51acf998754');
INSERT INTO public.categories VALUES (343, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Entertainment', 'Expense', '2aa9675d-cd52-4941-aa39-23c5bce4d721');
INSERT INTO public.categories VALUES (344, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Saving', 'Expense', '3c3d5e50-5e6e-4511-8d50-00d224193046');
INSERT INTO public.categories VALUES (345, '22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'Other', 'Expense', '1c2874ad-bb7d-4b8e-9441-5a5251033c6f');
INSERT INTO public.categories VALUES (306, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Salary', 'Income', '6fc1b2e6-6c36-476a-9694-ec912add101d');
INSERT INTO public.categories VALUES (307, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Extra Income', 'Income', '63266ef2-f83d-4f3b-b987-7dded24253e5');
INSERT INTO public.categories VALUES (308, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Food', 'Expense', '42bf43f8-856d-40db-99a6-955fbba955af');
INSERT INTO public.categories VALUES (309, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Transport', 'Expense', 'cc1aa9be-539e-4fe5-90a6-a6b635c7c569');
INSERT INTO public.categories VALUES (310, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Health', 'Expense', 'cd63f14b-9a47-4abf-84eb-e46154b75371');
INSERT INTO public.categories VALUES (311, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Shopping', 'Expense', '6223c467-4d6f-42b0-a4eb-03682ed3d7d2');
INSERT INTO public.categories VALUES (312, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Bills', 'Expense', '8a93ba2d-2ee1-4eb7-8c79-96ef0eaa947e');
INSERT INTO public.categories VALUES (313, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Entertainment', 'Expense', '9f5091bb-3ea1-479e-b041-8b26ad858279');
INSERT INTO public.categories VALUES (314, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Saving', 'Expense', 'a754fd04-23b9-4758-b8ab-1538fadcc6fc');
INSERT INTO public.categories VALUES (383, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Entertainment', 'Expense', '238db314-3c71-4797-87d6-b6997e8c0e46');
INSERT INTO public.categories VALUES (384, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Saving', 'Expense', '35b57b55-fd08-4ba8-862b-e117e896d2e6');
INSERT INTO public.categories VALUES (385, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Other', 'Expense', '45d21a31-f785-4200-9136-f0a061f0313e');
INSERT INTO public.categories VALUES (346, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Salary', 'Income', '5495058f-18bc-4aff-93f2-4af9052ec7a7');
INSERT INTO public.categories VALUES (347, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Extra Income', 'Income', '6195733b-d593-43ec-8703-bc2c7a7243a8');
INSERT INTO public.categories VALUES (348, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Food', 'Expense', 'e7bb2c20-011d-4070-9e02-a1008d8341a8');
INSERT INTO public.categories VALUES (349, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Transport', 'Expense', '81244a1c-464c-4ee7-bcec-834cd30cce1a');
INSERT INTO public.categories VALUES (350, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Health', 'Expense', 'f7c700cc-929c-4681-9203-4fd89edc50ee');
INSERT INTO public.categories VALUES (351, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Shopping', 'Expense', 'c7af5ee3-cebf-4257-98ad-c36c9ca280b8');
INSERT INTO public.categories VALUES (352, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Bills', 'Expense', 'b4bf7339-0f58-4ad7-bdec-e5cbc76cf9c0');
INSERT INTO public.categories VALUES (353, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Entertainment', 'Expense', '7358ec4b-803c-4321-b198-49febcea4fe7');
INSERT INTO public.categories VALUES (354, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Saving', 'Expense', 'b8fb2bd1-5f9f-4f63-8917-a889086c179a');
INSERT INTO public.categories VALUES (355, '26da5e42-b707-44fb-94a0-34121e8ce20f', 'Other', 'Expense', 'ced5885b-78a7-4caf-992b-13f0f8c5299b');
INSERT INTO public.categories VALUES (406, '1141aa56-463c-40e8-8f86-73e18095541c', 'Salary', 'Income', '6e7ccb6c-9eba-4934-adc5-655a9286ac2a');
INSERT INTO public.categories VALUES (407, '1141aa56-463c-40e8-8f86-73e18095541c', 'Extra Income', 'Income', '9a03afb4-9376-4ef8-94f5-8ae4cb9ace71');
INSERT INTO public.categories VALUES (408, '1141aa56-463c-40e8-8f86-73e18095541c', 'Food', 'Expense', 'f8360f75-164e-438f-8f64-cc267c704449');
INSERT INTO public.categories VALUES (409, '1141aa56-463c-40e8-8f86-73e18095541c', 'Transport', 'Expense', '29034dac-0ac3-47ea-a52a-d2b6f652a57c');
INSERT INTO public.categories VALUES (410, '1141aa56-463c-40e8-8f86-73e18095541c', 'Health', 'Expense', '1dc71ba2-c10a-4b95-bc80-f956ff3be3f6');
INSERT INTO public.categories VALUES (411, '1141aa56-463c-40e8-8f86-73e18095541c', 'Shopping', 'Expense', '2627f367-f5e1-4478-ad4b-2b0145475890');
INSERT INTO public.categories VALUES (412, '1141aa56-463c-40e8-8f86-73e18095541c', 'Bills', 'Expense', '9efb7e75-0ccd-4eca-a91c-8d502998cbf3');
INSERT INTO public.categories VALUES (413, '1141aa56-463c-40e8-8f86-73e18095541c', 'Entertainment', 'Expense', 'd495d681-7b30-4e88-8d0c-8d615575bfe4');
INSERT INTO public.categories VALUES (414, '1141aa56-463c-40e8-8f86-73e18095541c', 'Saving', 'Expense', '3b074fe2-5111-4169-9d98-1f129e5fea95');
INSERT INTO public.categories VALUES (415, '1141aa56-463c-40e8-8f86-73e18095541c', 'Other', 'Expense', '482d6b88-4c20-4666-a5e4-41eb68cb74ca');
INSERT INTO public.categories VALUES (326, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Salary', 'Income', 'b8c6e92d-5b76-42c5-92a5-8cc7130be181');
INSERT INTO public.categories VALUES (327, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Extra Income', 'Income', 'd8887c69-95bb-4cc2-8aad-698d273c0617');
INSERT INTO public.categories VALUES (328, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Food', 'Expense', 'b64e781d-78d7-4983-86bf-8ca7a8ecfef0');
INSERT INTO public.categories VALUES (329, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Transport', 'Expense', '2179cbd8-0130-471f-8bb3-6871307e48b5');
INSERT INTO public.categories VALUES (330, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Health', 'Expense', '6bb4d0ef-33d3-474f-b224-66d932c7f7a6');
INSERT INTO public.categories VALUES (331, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Shopping', 'Expense', '4366aea2-8d20-4840-a4c5-e6eef2458225');
INSERT INTO public.categories VALUES (332, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Bills', 'Expense', 'a01ff4ae-4ac9-4abb-ab42-cc27cf42454a');
INSERT INTO public.categories VALUES (333, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Entertainment', 'Expense', '85fb9a5a-d19b-47ef-9a3c-b34de845d8d4');
INSERT INTO public.categories VALUES (334, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Saving', 'Expense', '983175ec-92e0-4a3d-b728-f9638f091e4c');
INSERT INTO public.categories VALUES (335, '7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'Other', 'Expense', 'e203bb28-2a7a-48e6-ab84-ca866be12d50');
INSERT INTO public.categories VALUES (396, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Salary', 'Income', '0ad2f8fe-42fb-4022-ad19-7c8d17b3edf9');
INSERT INTO public.categories VALUES (397, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Extra Income', 'Income', 'a0f3404c-e1a2-4305-bd31-5e8584b5c5ec');
INSERT INTO public.categories VALUES (398, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Food', 'Expense', '2d409fe9-0dc1-40cd-a6aa-e19f41c67fa7');
INSERT INTO public.categories VALUES (399, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Transport', 'Expense', '15da8d32-d275-49f1-9c80-d51fae2f74a3');
INSERT INTO public.categories VALUES (400, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Health', 'Expense', '038f4e4f-d88c-4396-b0f7-69e03cea6b79');
INSERT INTO public.categories VALUES (401, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Shopping', 'Expense', '45986df9-82f7-4bb3-8976-80cafddb620d');
INSERT INTO public.categories VALUES (402, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Bills', 'Expense', 'a1995576-6ec6-4945-93d3-6ff8b717bd1a');
INSERT INTO public.categories VALUES (403, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Entertainment', 'Expense', '7b150291-5535-486a-943f-f75d57b457bc');
INSERT INTO public.categories VALUES (404, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Saving', 'Expense', '1b4193c7-d429-4f3f-9f16-0436a289f580');
INSERT INTO public.categories VALUES (405, '7cc650c8-16c6-4937-8347-199ffb28f650', 'Other', 'Expense', 'a4cad155-cafd-4fa4-938f-2707be89eb45');
INSERT INTO public.categories VALUES (356, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Salary', 'Income', 'b1cb32b8-c38f-48be-9737-00b3627cd076');
INSERT INTO public.categories VALUES (357, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Extra Income', 'Income', '2df5c2e0-6d39-441c-b8a7-6bbf9db16e89');
INSERT INTO public.categories VALUES (358, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Food', 'Expense', '5879996c-33ae-4722-ad2c-281eb40e7ee3');
INSERT INTO public.categories VALUES (359, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Transport', 'Expense', '4905926f-91a3-4ebc-a780-20454b364bc5');
INSERT INTO public.categories VALUES (360, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Health', 'Expense', '76bd7009-e11a-4a6c-a013-c9b059a65946');
INSERT INTO public.categories VALUES (361, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Shopping', 'Expense', '1264d33d-7af2-4832-a067-3e4adb088bc0');
INSERT INTO public.categories VALUES (362, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Bills', 'Expense', 'b270d7da-92bb-4b95-b1f8-83ec1f2effee');
INSERT INTO public.categories VALUES (363, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Entertainment', 'Expense', 'f0b13e60-ecb0-44b3-8e2f-537dde60cbe8');
INSERT INTO public.categories VALUES (364, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Saving', 'Expense', '648bd5f5-1af5-47d5-83d4-32e5e319f6a8');
INSERT INTO public.categories VALUES (365, '937c2768-1626-4167-8e9c-fcfc2358e3f4', 'Other', 'Expense', '548552b0-5e6e-4afc-8e06-a5f26b1062d9');
INSERT INTO public.categories VALUES (316, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Salary', 'Income', 'fff011c0-bfcc-4c49-9720-0440f61cd019');
INSERT INTO public.categories VALUES (317, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Extra Income', 'Income', '935faa1f-0ce0-449d-a8c4-9ef9fd37c654');
INSERT INTO public.categories VALUES (318, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Food', 'Expense', 'cc722ba5-7369-4778-bebc-6ed712230b41');
INSERT INTO public.categories VALUES (319, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Transport', 'Expense', '61d9a0ab-698b-474f-a11d-7bf70645efe1');
INSERT INTO public.categories VALUES (386, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Salary', 'Income', '269d042c-5859-4cea-bfcf-ab4befc01e93');
INSERT INTO public.categories VALUES (387, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Extra Income', 'Income', '8abacd55-2c52-4af3-838e-ae8054cfe361');
INSERT INTO public.categories VALUES (388, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Food', 'Expense', '0355c225-37bf-4061-b938-25dc1c188a54');
INSERT INTO public.categories VALUES (389, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Transport', 'Expense', 'bf19b4a9-dad3-449d-acae-47b59718ab60');
INSERT INTO public.categories VALUES (390, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Health', 'Expense', '4cb9fb10-1633-41e7-8b10-05b2d00fcfd0');
INSERT INTO public.categories VALUES (391, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Shopping', 'Expense', 'ee42acf7-65ce-4311-89a6-cd60d43fae20');
INSERT INTO public.categories VALUES (392, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Bills', 'Expense', '33a6e87a-7f50-4043-ba58-b9ce56d64786');
INSERT INTO public.categories VALUES (393, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Entertainment', 'Expense', '09bbc44c-fb39-4ff3-9eb1-f28ee33acf2e');
INSERT INTO public.categories VALUES (394, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Saving', 'Expense', 'a9857aed-bc54-4a83-bece-d01ea64930bb');
INSERT INTO public.categories VALUES (395, '4d22eeac-ddb7-4499-88af-806d3340d8fd', 'Other', 'Expense', 'a2305cd8-cd2a-4bd0-8eac-4c8a9c25debe');
INSERT INTO public.categories VALUES (366, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Salary', 'Income', 'fa6cdfd0-a10c-4894-8a03-20fd1f654dc3');
INSERT INTO public.categories VALUES (367, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Extra Income', 'Income', '8dd50f34-1529-43db-98b4-bc870774b051');
INSERT INTO public.categories VALUES (368, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Food', 'Expense', '781a4032-710f-4a86-b72d-a59944329192');
INSERT INTO public.categories VALUES (369, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Transport', 'Expense', '8af73f88-e67a-40ff-b9d4-0a093e03a217');
INSERT INTO public.categories VALUES (370, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Health', 'Expense', '888d75de-cf39-407d-b2df-ed78cecaa79c');
INSERT INTO public.categories VALUES (371, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Shopping', 'Expense', '8b36b60c-6d5e-42e6-bbbd-06b87fdabb88');
INSERT INTO public.categories VALUES (372, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Bills', 'Expense', '54aa07db-8c9e-494a-addb-ccaf5f70a404');
INSERT INTO public.categories VALUES (373, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Entertainment', 'Expense', '8f57746d-640b-4633-935f-3a410c2f9a75');
INSERT INTO public.categories VALUES (374, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Saving', 'Expense', '30aacf0f-7d8a-47ed-b903-7e71f168b44e');
INSERT INTO public.categories VALUES (375, '075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'Other', 'Expense', '4297c4af-119c-4b38-b852-152006f0c39e');
INSERT INTO public.categories VALUES (315, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'Other', 'Expense', '7bd07565-8b87-45ad-9fc1-e675c2f2afe9');
INSERT INTO public.categories VALUES (320, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Health', 'Expense', 'cee129c7-ecc3-4dd4-bb2a-9fb31d1d30ab');
INSERT INTO public.categories VALUES (321, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Shopping', 'Expense', 'ddf0cd70-fad1-40a9-9db6-beee75002395');
INSERT INTO public.categories VALUES (322, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Bills', 'Expense', '1651eca7-c2cb-4440-80d3-81b66f220ec9');
INSERT INTO public.categories VALUES (323, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Entertainment', 'Expense', 'fed6c39b-1481-4938-930a-70f2571cb526');
INSERT INTO public.categories VALUES (324, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Saving', 'Expense', '86c1940a-f4e5-4a70-972f-0ee99a6b77b0');
INSERT INTO public.categories VALUES (325, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Other', 'Expense', 'e4d2c20d-1a65-4986-b561-2ce9467b16a0');
INSERT INTO public.categories VALUES (296, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Salary', 'Income', 'd2bb377a-aee2-4abd-b16d-49e04956b5ef');
INSERT INTO public.categories VALUES (297, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Extra Income', 'Income', '1902b23c-e881-4afa-8791-47040786240e');
INSERT INTO public.categories VALUES (298, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Food', 'Expense', 'a165cf38-1718-4ed3-af63-62d504ee7e5a');
INSERT INTO public.categories VALUES (299, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Transport', 'Expense', '67b14b9b-63d5-4b87-9150-685b28a68b83');
INSERT INTO public.categories VALUES (300, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Health', 'Expense', '58a56f70-c915-446f-a37f-1a8110bb20b2');
INSERT INTO public.categories VALUES (301, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Shopping', 'Expense', '9aff73f2-1943-4849-a62a-2e62e4052547');
INSERT INTO public.categories VALUES (302, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Bills', 'Expense', 'cefba24b-23c8-4904-b526-25d863b3a2bc');
INSERT INTO public.categories VALUES (303, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Entertainment', 'Expense', 'd3290c5c-0188-4817-8c64-f289de95dc7e');
INSERT INTO public.categories VALUES (304, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Saving', 'Expense', '79a3fa44-c590-40c7-b2ea-eae71f519576');
INSERT INTO public.categories VALUES (305, '9db8aa73-7870-4481-a109-6430ca921dd5', 'Other', 'Expense', '528f33f2-09f2-4ffe-a64c-856df0ab045d');
INSERT INTO public.categories VALUES (276, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Salary', 'Income', 'ed1ec8bb-8bcd-4164-a28e-8ae026113663');
INSERT INTO public.categories VALUES (277, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Extra Income', 'Income', 'c65bf0d7-4daf-4618-9d2c-15213bbec5aa');
INSERT INTO public.categories VALUES (278, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Food', 'Expense', 'a7b314ad-aab2-4447-b30b-7534d223c473');
INSERT INTO public.categories VALUES (279, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Transport', 'Expense', 'd98b70a0-9feb-4b6e-b38d-b6197c11e506');
INSERT INTO public.categories VALUES (280, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Health', 'Expense', '0ddb87dc-6327-4335-8f2a-2b823ff4e266');
INSERT INTO public.categories VALUES (281, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Shopping', 'Expense', '6f70b85c-3699-4e01-adcf-e00ee77b9dfd');
INSERT INTO public.categories VALUES (282, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Bills', 'Expense', '6c2b76ad-171f-42c5-a3ec-dc7d152802e4');
INSERT INTO public.categories VALUES (283, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Entertainment', 'Expense', '048ce1c6-04ed-4c6c-a9cf-321fc5d82451');
INSERT INTO public.categories VALUES (284, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Saving', 'Expense', '8fc26b05-0109-47b9-bdf3-6eab90852286');
INSERT INTO public.categories VALUES (285, 'f69c0230-b36a-4029-b128-d005743a0efb', 'Other', 'Expense', 'a2be1c73-f0e1-4d24-afca-a7a0d25149a2');
INSERT INTO public.categories VALUES (286, '0f43a469-1931-4108-8d76-81f5b8604168', 'Salary', 'Income', '32451362-0e1a-4177-a9dc-4d896225a885');
INSERT INTO public.categories VALUES (287, '0f43a469-1931-4108-8d76-81f5b8604168', 'Extra Income', 'Income', '4593e2ad-754f-4c6a-b437-e1e69985ba25');
INSERT INTO public.categories VALUES (288, '0f43a469-1931-4108-8d76-81f5b8604168', 'Food', 'Expense', '933ad0ce-adf5-485d-9c12-9d8b87470090');
INSERT INTO public.categories VALUES (289, '0f43a469-1931-4108-8d76-81f5b8604168', 'Transport', 'Expense', 'be210da0-032b-4f78-8686-fa02c0096e19');
INSERT INTO public.categories VALUES (290, '0f43a469-1931-4108-8d76-81f5b8604168', 'Health', 'Expense', '52bdcbb5-4231-49af-94ee-8f92e81f8fca');
INSERT INTO public.categories VALUES (291, '0f43a469-1931-4108-8d76-81f5b8604168', 'Shopping', 'Expense', '84ef4dbb-a4c0-4b5e-b7d6-79ea228936f7');
INSERT INTO public.categories VALUES (292, '0f43a469-1931-4108-8d76-81f5b8604168', 'Bills', 'Expense', 'b63b65ff-656b-4492-b55d-730d4ab9ffc4');
INSERT INTO public.categories VALUES (293, '0f43a469-1931-4108-8d76-81f5b8604168', 'Entertainment', 'Expense', '4c28c838-f80b-4d5a-9a91-f2e2dc141021');
INSERT INTO public.categories VALUES (294, '0f43a469-1931-4108-8d76-81f5b8604168', 'Saving', 'Expense', 'f3f1c127-59c9-460f-aacd-769c3098365a');
INSERT INTO public.categories VALUES (295, '0f43a469-1931-4108-8d76-81f5b8604168', 'Other', 'Expense', '2871a586-f004-46cc-b761-37e3675e0ae2');
INSERT INTO public.categories VALUES (376, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Salary', 'Income', 'cf6f73d8-b049-489f-b94f-6a0b7fd801d6');
INSERT INTO public.categories VALUES (377, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Extra Income', 'Income', '11a189ab-5a72-48a7-ac8c-8bb00a0bf79e');
INSERT INTO public.categories VALUES (378, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Food', 'Expense', 'cbec0f99-e798-4765-be51-0784be957b96');
INSERT INTO public.categories VALUES (379, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Transport', 'Expense', 'b98c7a71-bf18-4000-acb3-4f1101fb3b6d');
INSERT INTO public.categories VALUES (380, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Health', 'Expense', 'f73d140b-384e-454f-9711-fd749961ff36');
INSERT INTO public.categories VALUES (381, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Shopping', 'Expense', '1695ce27-7258-4b3c-9b97-7ec462c9cb32');
INSERT INTO public.categories VALUES (382, 'ad077fba-5186-4b68-97e1-6c84b6901fc1', 'Bills', 'Expense', 'a9283667-d107-48dd-86a1-5ba888193493');


--
-- TOC entry 3588 (class 0 OID 16875)
-- Dependencies: 217
-- Data for Name: debt; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.debt VALUES ('1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 500.00, 5.0000, 5, '2026-03-30 00:00:00', true, 0, 6, 'rrrr', 4.00, 1, '2027-03-30 00:00:00', 'c7157984-89d3-48ae-a619-84a4890f7a60', 5.00, 0.00, 0, 5.0000, 40, 30, false, true, 'MONTHLY', 'MONTHLY', 0.00, 5.00, 55.00, 0.00);
INSERT INTO public.debt VALUES ('9db8aa73-7870-4481-a109-6430ca921dd5', 3500000.00, 3.2500, 6, '2026-04-07 00:00:00', true, 2, 5, 'บ้านหลังแรกกกก', 18500.00, 1, '2054-04-07 00:00:00', '5c6bf689-bbfb-4b71-9a34-c720fb25fd53', 3250000.00, 0.00, 0, 0.0000, 0, 0, false, false, 'YEARLY', 'MONTHLY', 0.00, 0.00, 0.00, 0.00);
INSERT INTO public.debt VALUES ('9db8aa73-7870-4481-a109-6430ca921dd5', 850000.00, 2.1000, 6, '2026-04-07 00:00:00', true, 3, 4, 'สินเชื่อเช่ารถ', 14200.00, 10, '2028-04-07 00:00:00', '18fd7cb9-d0e7-4e65-bcde-10149589bd5f', 620000.00, 0.00, 3, 0.0000, 0, 0, false, false, 'YEARLY', 'MONTHLY', 0.00, 0.00, 0.00, 0.00);
INSERT INTO public.debt VALUES ('9db8aa73-7870-4481-a109-6430ca921dd5', 45000.00, 16.0000, 7, '2026-04-04 00:00:00', true, 0, 3, 'บัตรเครดิต KBank Shopee', 2500.00, 20, '2027-04-04 00:00:00', '1a7c7973-1bc3-4661-91b2-b90e31755fb2', 38500.00, 0.00, 0, 2.0000, 5, 5, false, false, 'MONTHLY', 'MONTHLY', 0.00, 2.00, 300.00, 0.00);
INSERT INTO public.debt VALUES ('0f43a469-1931-4108-8d76-81f5b8604168', 50000.00, 16.0000, 7, '2026-03-01 07:00:00', true, 3, 3, 'บัตรเครดิต K-Bank (Platinum)', 500.00, 5, '2027-03-01 07:00:00', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 36070.40, 0.00, 0, NULL, 0, 0, false, false, 'YEARLY', 'MONTHLY', 1140.40, 0.00, 0.00, 0.00);
INSERT INTO public.debt VALUES ('0f43a469-1931-4108-8d76-81f5b8604168', 23000.00, 2.0000, 5, '2026-03-28 00:00:00', true, 1, 2, 'กู้เงินนอกระบบ (เฮียเจี้ยง)', 0.00, 30, '2026-09-28 00:00:00', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 23000.00, 0.00, 1, 0.0000, 0, 0, false, true, 'MONTHLY', 'MONTHLY', 12020.00, 0.00, 0.00, 0.00);
INSERT INTO public.debt VALUES ('0f43a469-1931-4108-8d76-81f5b8604168', 100000.00, 25.0000, 6, '2026-03-29 07:00:00', true, 2, 2, 'สินเชื่อบุคคล UOB i-Cash', 4500.00, 1, '2028-03-29 07:00:00', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 94650.90, 0.00, 0, NULL, 0, 0, false, false, 'YEARLY', 'MONTHLY', 6105.90, 0.00, 0.00, 0.00);
INSERT INTO public.debt VALUES ('0f43a469-1931-4108-8d76-81f5b8604168', 100000.00, 2.0000, 6, '2026-04-19 00:00:00', true, 4, 5, 'หนี้บ้าน', 0.00, 1, '2027-04-19 00:00:00', 'e0222a57-4294-48ce-9bd1-ae4f3668db23', 100000.00, 0.00, 0, 0.0000, 0, 0, false, false, 'YEARLY', 'MONTHLY', 0.00, 0.00, 0.00, 0.00);
INSERT INTO public.debt VALUES ('0f43a469-1931-4108-8d76-81f5b8604168', 50000.00, 2.0000, 5, '2026-04-27 00:00:00', true, 5, 2, 'หนี้รถ', 0.00, 1, '2027-04-27 00:00:00', 'd9cffec7-8a6d-47f6-8bad-46b819888e28', 40083.33, 0.00, 0, 0.0000, 0, 0, false, false, 'YEARLY', 'MONTHLY', 83.33, 0.00, 0.00, 0.00);


--
-- TOC entry 3589 (class 0 OID 16882)
-- Dependencies: 218
-- Data for Name: debt_statement; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3590 (class 0 OID 16889)
-- Dependencies: 219
-- Data for Name: debt_transactions; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.debt_transactions VALUES ('36e4f2c9-3a5e-4372-af5e-16c8a3030dfa', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'INTEREST_CHARGE', 5.00, '2026-03-30', NULL, '2026-03-30 05:20:40.568255', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('028f4bbc-188f-4954-875c-b1346f19a4e8', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PAYMENT', 5.00, '2026-03-30', NULL, '2026-03-30 05:21:35.966375', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('9867d1f0-5788-47e0-b6ca-c1e6d31b8e2f', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'LATE_FEE_PAYMENT', 5.00, '2026-03-30', NULL, '2026-03-30 05:21:35.967446', '112b1b05-5ddf-401a-ba17-e540e103c039', NULL);
INSERT INTO public.debt_transactions VALUES ('cad0c2c6-5221-4c4e-b4f6-a6414901c1e3', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 50.00, '2026-04-27', NULL, '2026-04-27 13:54:09.973331', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('07fd3bc4-6ce4-4be0-bf5e-ae11225671b2', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PAYMENT', 5.00, '2026-03-30', NULL, '2026-03-30 05:21:47.225601', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('0785987f-4141-4247-b609-dc58e5094611', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'LATE_FEE_PAYMENT', 5.00, '2026-03-30', NULL, '2026-03-30 05:21:47.226511', '112b1b05-5ddf-401a-ba17-e540e103c039', NULL);
INSERT INTO public.debt_transactions VALUES ('112b1b05-5ddf-401a-ba17-e540e103c039', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'LATE_FEE_CHARGE', 45.00, '2026-03-30', NULL, '2026-03-30 05:20:40.57302', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('3a80c7e7-500e-429a-80cc-d72e4223a912', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 50.00, '2026-04-27', NULL, '2026-04-27 13:54:09.975', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('5bcf76aa-db8c-41e6-a377-5ead88ab84f6', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PAYMENT', 1000.00, '2026-04-27', NULL, '2026-04-27 14:52:52.680408', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('8073bb97-7456-45a0-91d0-fc4e787df990', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_PAYMENT', 1000.00, '2026-04-27', NULL, '2026-04-27 14:52:52.682574', '3eaa9a02-1d15-41ef-9208-395ba7b3b1c1', NULL);
INSERT INTO public.debt_transactions VALUES ('9fdc8b3c-6487-44d9-a295-9955cc820ddf', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'INTEREST_CHARGE', 0.25, '2026-05-01', NULL, '2026-05-01 01:00:00.003473', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('f7a51088-e66f-4e02-b965-03a7b071868c', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'LATE_FEE_CHARGE', 0.02, '2026-05-01', NULL, '2026-05-01 01:00:00.012314', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('8f0a43a4-2376-4d62-b735-6c5400267cdb', '5c6bf689-bbfb-4b71-9a34-c720fb25fd53', 'INTEREST_CHARGE', 8802.08, '2026-05-01', NULL, '2026-05-01 01:00:00.015672', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('817d5ac0-cda0-49ff-add8-cbdfd09684da', '18fd7cb9-d0e7-4e65-bcde-10149589bd5f', 'INTEREST_CHARGE', 1085.00, '2026-05-01', NULL, '2026-05-01 01:00:00.018536', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('7bb92414-536f-44b6-af17-d9a7bcca798a', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_CHARGE', 460.00, '2026-05-01', NULL, '2026-05-01 01:00:00.020148', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('59f8ea1e-c84a-41d3-bcd9-285356beeb80', '1a7c7973-1bc3-4661-91b2-b90e31755fb2', 'INTEREST_CHARGE', 6160.00, '2026-05-01', NULL, '2026-05-01 01:00:00.021519', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('5dc1844c-54e4-4543-8122-e3ce3ae39ddc', '1a7c7973-1bc3-4661-91b2-b90e31755fb2', 'LATE_FEE_CHARGE', 64.17, '2026-05-01', NULL, '2026-05-01 01:00:00.023233', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('68779915-15da-4577-8225-86599df0f3c6', 'd9cffec7-8a6d-47f6-8bad-46b819888e28', 'INTEREST_CHARGE', 66.81, '2026-05-01', NULL, '2026-05-01 01:00:00.02561', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('2334b12c-7b82-40e0-b334-edb4760e14a9', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'INTEREST_CHARGE', 480.94, '2026-05-01', NULL, '2026-05-01 01:00:00.03569', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('659043af-c06e-458d-9b07-d79a058ddbe9', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 1000.00, '2026-04-27', NULL, '2026-04-27 11:07:39.453552', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('21891c67-a91e-4590-becf-8641e36751aa', 'e0222a57-4294-48ce-9bd1-ae4f3668db23', 'INTEREST_CHARGE', 166.67, '2026-05-01', NULL, '2026-05-01 01:00:00.039664', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('837d2495-160b-402e-8e24-2005c3fc68e7', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'INTEREST_CHARGE', 0.25, '2026-04-01', NULL, '2026-04-01 01:00:00.056959', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('0deb5aa9-c943-4209-8d17-5e60be5b141b', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PAYMENT', 5000.00, '2026-03-29', NULL, '2026-03-29 04:26:16.560358', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('76f71b18-4ce7-4269-bec8-2a4ac74d3198', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'INTEREST_PAYMENT', 600.00, '2026-03-29', NULL, '2026-03-29 04:26:16.774223', 'd8c8307b-25f6-44ad-9a61-0a1892a4fdfa', NULL);
INSERT INTO public.debt_transactions VALUES ('0410364d-8871-49cf-9fe0-a69402da8d22', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PRINCIPAL_PAYMENT', 4400.00, '2026-03-29', NULL, '2026-03-29 04:26:16.775493', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('d8c8307b-25f6-44ad-9a61-0a1892a4fdfa', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'INTEREST_CHARGE', 0.00, '2026-03-01', NULL, '2026-03-29 04:26:16.659062', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('fc004724-a389-495a-9c9d-3ba986e8a63d', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 1000.00, '2026-04-27', NULL, '2026-04-27 11:07:39.455403', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('c3dffe77-3b43-4524-ab5c-a0df760b79df', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 105.00, '2026-04-27', NULL, '2026-04-27 11:10:43.321692', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('80c632bd-3333-4b7f-bb52-d75e5b19bfe0', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 5000.00, '2026-03-29', NULL, '2026-03-29 14:13:44.428448', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('498a83a4-2304-4ad2-8788-8a9e632641d8', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_PAYMENT', 2083.33, '2026-03-29', NULL, '2026-03-29 14:13:44.502692', '39b32ab1-0aa9-461e-8560-d86ca71223cf', NULL);
INSERT INTO public.debt_transactions VALUES ('98c48e8a-e519-4d56-8680-e0a9feb91cff', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 2916.67, '2026-03-29', NULL, '2026-03-29 14:13:44.503393', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('39b32ab1-0aa9-461e-8560-d86ca71223cf', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_CHARGE', 0.00, '2026-03-29', NULL, '2026-03-29 14:13:44.46914', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('26956249-3323-4af6-9e99-2766182c1c1f', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PAYMENT', 20.00, '2026-03-29', NULL, '2026-03-29 15:21:03.841176', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('d4a0550c-f866-4514-94ae-cbba57cab301', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_PAYMENT', 20.00, '2026-03-29', NULL, '2026-03-29 15:21:05.519497', '07485e6d-d71a-49cb-9067-858c26e93992', NULL);
INSERT INTO public.debt_transactions VALUES ('8154c0fa-494a-47c7-b99f-9a50f665ad3d', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PAYMENT', 70.00, '2026-03-29', NULL, '2026-03-29 16:17:32.121474', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('ee8fa3cb-0a2c-401f-a252-0d7a0475a036', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PRINCIPAL_PAYMENT', 70.00, '2026-03-29', NULL, '2026-03-29 16:17:32.225301', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('63e5e04e-a686-4ddb-b765-47d6e01ab21c', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 105.00, '2026-04-27', NULL, '2026-04-27 11:10:43.323827', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('6c7a1db7-41c8-40c9-a9b7-f8928387401b', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PAYMENT', 1000.00, '2026-04-07', NULL, '2026-04-07 15:11:49.901755', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('4a2b1ea9-52cc-42ee-b775-f1b1d03f126b', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_PAYMENT', 980.00, '2026-04-07', NULL, '2026-04-07 15:11:49.904186', '07485e6d-d71a-49cb-9067-858c26e93992', NULL);
INSERT INTO public.debt_transactions VALUES ('7bc0059f-f7e7-4f5d-95f5-d65339685113', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_PAYMENT', 20.00, '2026-04-07', NULL, '2026-04-07 15:11:49.904309', '3eaa9a02-1d15-41ef-9208-395ba7b3b1c1', NULL);
INSERT INTO public.debt_transactions VALUES ('07485e6d-d71a-49cb-9067-858c26e93992', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_CHARGE', 0.00, '2026-03-29', NULL, '2026-03-29 15:21:03.929677', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('ff85a679-cbb5-4eca-9503-7cee9b8c510e', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 100.00, '2026-04-27', NULL, '2026-04-27 11:34:06.499615', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('86e5195a-34bd-44a0-8350-dfc7a4457124', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 1000.00, '2026-04-07', NULL, '2026-04-07 15:12:09.981865', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('2693ea2a-0515-4e56-a0bf-9964abc2b637', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_PAYMENT', 1000.00, '2026-04-07', NULL, '2026-04-07 15:12:09.98415', '592f4d89-0720-481b-b207-b19abf4e72b2', NULL);
INSERT INTO public.debt_transactions VALUES ('aeafd217-20f6-4fda-9c31-3c41f3ce0de7', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PAYMENT', 5000.00, '2026-04-27', NULL, '2026-04-27 09:36:30.168063', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('6ed51bc0-b80d-4e5a-b5c5-b83c66fbd1e0', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_PAYMENT', 5000.00, '2026-04-27', NULL, '2026-04-27 09:36:30.173746', '3eaa9a02-1d15-41ef-9208-395ba7b3b1c1', NULL);
INSERT INTO public.debt_transactions VALUES ('1495b933-3f66-4610-9881-45ba14ad00c4', 'd9cffec7-8a6d-47f6-8bad-46b819888e28', 'PAYMENT', 10000.00, '2026-04-27', NULL, '2026-04-27 10:16:15.273106', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('02a63143-f024-4c51-aa63-672e2a0a03c8', 'd9cffec7-8a6d-47f6-8bad-46b819888e28', 'INTEREST_PAYMENT', 83.33, '2026-04-27', NULL, '2026-04-27 10:16:15.275199', 'a3f5215f-800c-4301-9881-1ffad1e93f0c', NULL);
INSERT INTO public.debt_transactions VALUES ('614fa3b4-3ae4-4057-b226-f93ee5ccaec6', 'd9cffec7-8a6d-47f6-8bad-46b819888e28', 'PRINCIPAL_PAYMENT', 9916.67, '2026-04-27', NULL, '2026-04-27 10:16:15.275314', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('a3f5215f-800c-4301-9881-1ffad1e93f0c', 'd9cffec7-8a6d-47f6-8bad-46b819888e28', 'INTEREST_CHARGE', 0.00, '2026-04-27', NULL, '2026-04-27 10:16:15.270638', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('deb04c51-790f-4bd8-835b-9f97e8016ef5', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PAYMENT', 5000.00, '2026-04-27', NULL, '2026-04-27 10:40:22.780432', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('00ab3438-8796-4050-ab77-64530c9f3018', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'INTEREST_PAYMENT', 540.40, '2026-04-27', NULL, '2026-04-27 10:40:22.782777', '8a334d9f-a9da-422f-9bd0-bf2cddc3b161', NULL);
INSERT INTO public.debt_transactions VALUES ('45d49884-1c1d-4a6f-bbd5-4c3720509a16', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PRINCIPAL_PAYMENT', 4459.60, '2026-04-27', NULL, '2026-04-27 10:40:22.782947', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('8a334d9f-a9da-422f-9bd0-bf2cddc3b161', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'INTEREST_CHARGE', 0.00, '2026-04-01', NULL, '2026-04-01 01:00:00.063453', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('3dd179f1-a78a-4cf1-99a6-02d345de9c52', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 1000.00, '2026-04-27', NULL, '2026-04-27 10:47:35.531004', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('a57cfe54-dcbb-4327-b5be-ad173a9c1107', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_PAYMENT', 1000.00, '2026-04-27', NULL, '2026-04-27 10:47:35.5326', '592f4d89-0720-481b-b207-b19abf4e72b2', NULL);
INSERT INTO public.debt_transactions VALUES ('115f06c1-3ab5-49b8-b60c-b6388706a32b', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 100.00, '2026-04-27', NULL, '2026-04-27 11:34:06.501558', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('bd1ba522-3ea3-4863-939a-6c3e9205a992', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 1000.00, '2026-04-27', NULL, '2026-04-27 11:01:00.100107', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('c4786ce5-c333-4746-9a25-a92cf35142b7', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_PAYMENT', 22.57, '2026-04-27', NULL, '2026-04-27 11:01:00.10257', '592f4d89-0720-481b-b207-b19abf4e72b2', NULL);
INSERT INTO public.debt_transactions VALUES ('39b3c5b4-3218-44d8-9eec-f9a601adb989', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 977.43, '2026-04-27', NULL, '2026-04-27 11:01:00.102664', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('592f4d89-0720-481b-b207-b19abf4e72b2', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_CHARGE', 0.00, '2026-04-01', NULL, '2026-04-01 01:00:00.060328', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('6c24ec5f-b9c0-421e-8a15-d1fc4bddac76', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 100.00, '2026-04-27', NULL, '2026-04-27 11:44:55.061144', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('910171f8-baa7-4d43-96b2-c1bba060a1c2', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 100.00, '2026-04-27', NULL, '2026-04-27 11:44:55.062901', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('ad087de7-d8aa-4f29-a9ac-0b63a6d0e5a2', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 50.00, '2026-04-27', NULL, '2026-04-27 11:56:47.574482', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('3e9e0ad4-fd1f-43a1-b396-a1c0b02bf84d', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 50.00, '2026-04-27', NULL, '2026-04-27 11:56:47.576212', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('a5b95fa5-f70c-4997-9b80-9d74b624d03e', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 50.00, '2026-04-27', NULL, '2026-04-27 13:38:56.756405', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('e9146128-a210-4de5-9187-04d20caeffb3', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PRINCIPAL_PAYMENT', 50.00, '2026-04-27', NULL, '2026-04-27 13:38:56.75907', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('a2fb8706-0832-47f2-b1c5-f0dfc56ab6d8', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_CHARGE', 460.00, '2026-06-17', NULL, '2026-06-17 08:52:59.792634', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('4faf234a-e803-40c1-954b-5e5fc734bb9b', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PAYMENT', 5000.00, '2026-06-17', NULL, '2026-06-17 08:52:59.964385', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('5d988897-222e-43b5-84ad-1f8dfc12ae55', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_PAYMENT', 5000.00, '2026-06-17', NULL, '2026-06-17 08:53:00.028104', '3eaa9a02-1d15-41ef-9208-395ba7b3b1c1', NULL);
INSERT INTO public.debt_transactions VALUES ('3eaa9a02-1d15-41ef-9208-395ba7b3b1c1', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'INTEREST_CHARGE', 480.00, '2026-04-01', NULL, '2026-04-01 01:00:00.051754', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('9848ed4a-5a65-4ba3-8e1b-dd5f1db75cbe', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PAYMENT', 2000.00, '2026-06-17', NULL, '2026-06-17 08:54:24.155426', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('0d656072-1401-4ad4-94b2-76957284effa', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_PAYMENT', 1971.89, '2026-06-17', NULL, '2026-06-17 08:54:24.171745', 'b16c2cce-5740-475e-8be5-71a88e861553', NULL);
INSERT INTO public.debt_transactions VALUES ('d23f8def-9eed-4f83-8e53-fd9722a01a9b', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_PAYMENT', 28.11, '2026-06-17', NULL, '2026-06-17 08:54:24.172813', '64dcea43-9924-4aca-a580-3dafa00b65a7', NULL);
INSERT INTO public.debt_transactions VALUES ('64dcea43-9924-4aca-a580-3dafa00b65a7', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_CHARGE', 1943.78, '2026-06-17', NULL, '2026-06-17 08:54:24.131888', NULL, NULL);
INSERT INTO public.debt_transactions VALUES ('b16c2cce-5740-475e-8be5-71a88e861553', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'INTEREST_CHARGE', 0.00, '2026-05-01', NULL, '2026-05-01 01:00:00.030859', NULL, NULL);


--
-- TOC entry 3591 (class 0 OID 16894)
-- Dependencies: 220
-- Data for Name: debt_type; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.debt_type VALUES (2, 'เงินกู้ส่วนบุคคล', 'เงินกู้ส่วนบุคคล ผ่อนรายเดือน');
INSERT INTO public.debt_type VALUES (3, 'หนี้บัตรเครดิต', 'หนี้บัตรเครดิต คิดดอกเบี้ยรายวัน');
INSERT INTO public.debt_type VALUES (4, 'สินเชื่อรถยนต์', 'สินเชื่อรถยนต์');
INSERT INTO public.debt_type VALUES (5, 'สินเชื่อที่อยู่อาศัย', 'สินเชื่อที่อยู่อาศัย');
INSERT INTO public.debt_type VALUES (6, 'สินเชื่อเพื่อการศึกษา', 'สินเชื่อเพื่อการศึกษา');
INSERT INTO public.debt_type VALUES (7, 'หนี้ค่ารักษาพยาบาล', 'หนี้ค่ารักษาพยาบาล');
INSERT INTO public.debt_type VALUES (8, 'เงินกู้ธุรกิจ', 'เงินกู้ธุรกิจ');
INSERT INTO public.debt_type VALUES (9, 'เงินกู้ฉุกเฉิน', 'เงินกู้ฉุกเฉิน');
INSERT INTO public.debt_type VALUES (11, 'ยืมเงินจากครอบครัว/เพื่อน', 'ยืมเงินจากครอบครัว/เพื่อน');
INSERT INTO public.debt_type VALUES (12, 'ผ่อนสินค้า', 'ผ่อนสินค้า ผ่อนมือถือ ผ่อนเครื่องใช้ไฟฟ้า');
INSERT INTO public.debt_type VALUES (13, 'หนี้ภาษี', 'หนี้ภาษี');
INSERT INTO public.debt_type VALUES (14, 'หนี้นอกระบบ', 'หนี้นอกระบบ');
INSERT INTO public.debt_type VALUES (15, 'หนี้ กยศ.', 'หนี้ กยศ. หรือสินเชื่อการศึกษา');
INSERT INTO public.debt_type VALUES (16, 'ประเภทอื่นๆ', 'ประเภทอื่นๆ');


--
-- TOC entry 3594 (class 0 OID 16901)
-- Dependencies: 223
-- Data for Name: job_applications; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.job_applications VALUES (1, '2026-04-07 13:32:41.994505', '-7380980383047526105', 'content creator', 'Jooble', '9db8aa73-7870-4481-a109-6430ca921dd5');
INSERT INTO public.job_applications VALUES (2, '2026-04-07 13:36:22.554476', '4882423535668803087', 'ช่างทั่วไป (รายวัน)', 'Jooble', '9db8aa73-7870-4481-a109-6430ca921dd5');
INSERT INTO public.job_applications VALUES (3, '2026-04-07 08:23:28.346428', '1380934488948303271', 'ขับรถ 6 ล้อ', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (4, '2026-04-10 06:47:14.695679', '1380934488948303271', 'ขับรถ 6 ล้อ', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (5, '2026-04-27 02:26:22.877558', '1380934488948303271', 'ขับรถ 6 ล้อ', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (6, '2026-04-27 02:41:46.067147', '1380934488948303271', 'ขับรถ 6 ล้อ', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (7, '2026-04-27 02:51:32.066263', '7524412377311820101', 'ขับรถ รับ-ส่งรถ ให้ลูกค้า ประจำสนามบินสุวรรณภูมิ (รายได้ขั้นต่ำ 17,000 บาท ด่วนมาก)', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (8, '2026-04-27 03:01:13.56378', '4115816794099348509', 'พนักงาน ขับรถ', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (9, '2026-04-27 04:48:37.139391', '989239932602204165', 'วิศวกรไฟฟ้า หรือ คอมพิวเตอร์', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (10, '2026-04-27 05:26:37.202153', '989239932602204165', 'วิศวกรไฟฟ้า หรือ คอมพิวเตอร์', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (11, '2026-04-27 06:03:15.405476', '989239932602204165', 'วิศวกรไฟฟ้า หรือ คอมพิวเตอร์', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (12, '2026-04-27 06:42:14.938775', '989239932602204165', 'วิศวกรไฟฟ้า หรือ คอมพิวเตอร์', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (13, '2026-04-27 07:26:05.109317', '989239932602204165', 'วิศวกรไฟฟ้า หรือ คอมพิวเตอร์', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (14, '2026-04-27 07:39:54.728668', '-3060852504346790680', 'รับด่วน...+++ ธุรการประจำอพาร์ทเม้นท์ หลายอัตรา (ประจำสาขาอนุสาวรีย์ชัย และสาขาลาดพร้าว35) มีที่พัก เงินเดือน 15000-30000 สามารถสื่อสารภาษาอังกฤษ คอมพิวเตอร์ จะพิจารณาเป็นพิเศษ', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (15, '2026-04-27 08:32:27.360813', '989239932602204165', 'วิศวกรไฟฟ้า หรือ คอมพิวเตอร์', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');
INSERT INTO public.job_applications VALUES (16, '2026-04-27 08:53:15.000088', '-166674451160010054', 'นักวิชาการ สาขา ภาษาไทย', 'Jooble', '0f43a469-1931-4108-8d76-81f5b8604168');


--
-- TOC entry 3596 (class 0 OID 16907)
-- Dependencies: 225
-- Data for Name: notification_log; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.notification_log VALUES ('bdf70f3f-747d-4912-b335-b3166c77e5a8', 'f69c0230-b36a-4029-b128-d005743a0efb', '8fda1941-0175-47f0-84d9-278459da2072', 'BUDGET', 'b922d4cc-bfff-4e0d-848e-42c9d5ae6a8d', 'PUSH', 'FAILED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Bills คงเหลือ 50.0 บาท (95.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:24:15.405992', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('15423647-1099-4c4a-a4ec-791bc9a3deac', 'f69c0230-b36a-4029-b128-d005743a0efb', '8fda1941-0175-47f0-84d9-278459da2072', 'BUDGET', 'b922d4cc-bfff-4e0d-848e-42c9d5ae6a8d', 'PUSH', 'CLICKED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Bills คงเหลือ 50.0 บาท (95.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:24:15.408248', NULL, NULL);
INSERT INTO public.notification_log VALUES ('eea89405-aa35-4b8a-b8f0-4f195bccd009', 'f69c0230-b36a-4029-b128-d005743a0efb', '81287fb5-13bf-48a9-8765-bc7d746c2f8d', 'BUDGET', '0064a21b-9e1e-4ce2-86ba-e946e8e2c96a', 'PUSH', 'FAILED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Food คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:25:09.046133', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('2c009c0b-9328-4bda-8e26-ba16b85a4e0f', 'f69c0230-b36a-4029-b128-d005743a0efb', '81287fb5-13bf-48a9-8765-bc7d746c2f8d', 'BUDGET', '0064a21b-9e1e-4ce2-86ba-e946e8e2c96a', 'PUSH', 'CLICKED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Food คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:25:09.247438', NULL, NULL);
INSERT INTO public.notification_log VALUES ('68d3ada0-6d3a-49a2-8c29-f89d147651b4', 'f69c0230-b36a-4029-b128-d005743a0efb', '06ee6a4a-d527-4ec3-a98e-6e47aac23233', 'BUDGET', '3d1d3545-9301-4554-90d0-e64303bb0f8a', 'PUSH', 'FAILED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Entertainment คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:26:25.949255', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('6e9a4ea6-7694-4977-aa78-e10165b8494c', 'f69c0230-b36a-4029-b128-d005743a0efb', '06ee6a4a-d527-4ec3-a98e-6e47aac23233', 'BUDGET', '3d1d3545-9301-4554-90d0-e64303bb0f8a', 'PUSH', 'CLICKED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Entertainment คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:26:25.951225', NULL, NULL);
INSERT INTO public.notification_log VALUES ('a6bf6f9b-29a3-4ae4-ac25-8e097fc8e78f', 'f69c0230-b36a-4029-b128-d005743a0efb', 'e8d520da-5dc2-4136-967a-6344e52af5f4', 'BUDGET', '906a6215-7176-4053-9770-1a75578d4c69', 'PUSH', 'FAILED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Saving คงเหลือ 50.0 บาท (95.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:34:26.944674', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('8cd0aee2-00ac-4682-87b1-dc98f7cd1d91', 'f69c0230-b36a-4029-b128-d005743a0efb', 'e8d520da-5dc2-4136-967a-6344e52af5f4', 'BUDGET', '906a6215-7176-4053-9770-1a75578d4c69', 'PUSH', 'CLICKED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Saving คงเหลือ 50.0 บาท (95.00% ของงบประมาณทั้งหมด)', '2026-02-16 12:34:27.075236', NULL, NULL);
INSERT INTO public.notification_log VALUES ('38479388-35f0-40fe-b258-6b0f2b628170', '0f43a469-1931-4108-8d76-81f5b8604168', '4fed1521-f180-4a62-83be-5dfca57bf2b4', 'BUDGET', '844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณใกล้ครบกำหนด', 'หมวด Bills เหลืองบประมาณ 160.00 บาท (ใช้ไปแล้ว 92.00% ของงบทั้งหมด)', '2026-02-16 23:40:16.063595', NULL, NULL);
INSERT INTO public.notification_log VALUES ('e9ac5090-782c-4063-89d7-d09816cc3e87', '0f43a469-1931-4108-8d76-81f5b8604168', 'ce30b449-cf1d-46cc-9996-ad8b5772e1c2', 'BUDGET', '844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณใกล้ครบกำหนด', 'หมวด Bills เหลืองบประมาณ 60.00 บาท (ใช้ไปแล้ว 97.00% ของงบทั้งหมด)', '2026-02-16 23:40:31.519403', NULL, NULL);
INSERT INTO public.notification_log VALUES ('8a3b3ba2-e2f6-4ab0-be97-95944568de26', '0f43a469-1931-4108-8d76-81f5b8604168', 'cba7aa47-3672-44b9-8b3c-ef242860a2fc', 'BUDGET', '844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 40.00 บาท (ใช้ไป 102.00% ของงบทั้งหมด)', '2026-02-16 23:40:42.575726', NULL, NULL);
INSERT INTO public.notification_log VALUES ('756052cc-c721-4dd2-b02c-2ff0a3a572ec', '0f43a469-1931-4108-8d76-81f5b8604168', 'e7d392f9-34d0-4f44-80d9-b3a0f2c85251', 'BUDGET', '844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณใกล้ครบกำหนด', 'หมวด Bills เหลืองบประมาณ 460.00 บาท (ใช้ไปแล้ว 90.80% ของงบทั้งหมด)', '2026-02-16 23:41:18.838169', NULL, NULL);
INSERT INTO public.notification_log VALUES ('93d3c6ac-7700-4e38-9044-40823a15b658', 'f69c0230-b36a-4029-b128-d005743a0efb', 'fb284045-4c05-4307-90a2-69f80ed3dd4a', 'BUDGET', 'd89d882d-7e13-49e9-bc38-402edc4c8b47', 'PUSH', 'FAILED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Health คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', '2026-02-17 07:40:57.340847', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('a416cc8d-561d-43c1-a823-7aa598e349a3', 'f69c0230-b36a-4029-b128-d005743a0efb', 'fb284045-4c05-4307-90a2-69f80ed3dd4a', 'BUDGET', 'd89d882d-7e13-49e9-bc38-402edc4c8b47', 'PUSH', 'FAILED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Health คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', '2026-02-17 07:40:57.400481', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('372e61ed-bf16-43de-b335-478bb6ace3e7', 'f69c0230-b36a-4029-b128-d005743a0efb', 'fb284045-4c05-4307-90a2-69f80ed3dd4a', 'BUDGET', 'd89d882d-7e13-49e9-bc38-402edc4c8b47', 'PUSH', 'CLICKED', 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Health คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', '2026-02-17 07:40:57.402598', NULL, NULL);
INSERT INTO public.notification_log VALUES ('30a53788-e2dc-4d15-9c21-f9feebd19e09', '0f43a469-1931-4108-8d76-81f5b8604168', 'e93b9b96-bc59-4e73-b2e8-5f2a3748df86', 'DEBT', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PUSH', 'CLICKED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: สินเชื่อบุคคล UOB i-Cash', '2026-04-01 02:00:00.10318', NULL, 'DEBT:fc81d7f6-2120-4524-b575-f82c2f6bc80e:D-0');
INSERT INTO public.notification_log VALUES ('8b3552ae-068c-497a-84be-8e4bb342d4ec', 'f69c0230-b36a-4029-b128-d005743a0efb', '3d04276f-2500-48dc-bf55-6fba3f540baf', 'DEBT', '2cb305dc-796c-4c6d-8ef9-67496dc6dc8d', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-02-25): สินเชื่อบ้าน ธอส', '2026-02-22 02:00:00.241456', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2cb305dc-796c-4c6d-8ef9-67496dc6dc8d:D-3');
INSERT INTO public.notification_log VALUES ('3bc829a3-a18b-4f65-9bfe-c8472272b2d8', 'f69c0230-b36a-4029-b128-d005743a0efb', '3d04276f-2500-48dc-bf55-6fba3f540baf', 'DEBT', '2cb305dc-796c-4c6d-8ef9-67496dc6dc8d', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-02-25): สินเชื่อบ้าน ธอส', '2026-02-22 02:00:00.294268', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2cb305dc-796c-4c6d-8ef9-67496dc6dc8d:D-3');
INSERT INTO public.notification_log VALUES ('889769d8-a2db-4882-b492-a7b7f7bd6e7e', 'f69c0230-b36a-4029-b128-d005743a0efb', '3d04276f-2500-48dc-bf55-6fba3f540baf', 'DEBT', '2cb305dc-796c-4c6d-8ef9-67496dc6dc8d', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-02-25) ครบกำหนดชำระหนี้: สินเชื่อบ้าน ธอส', '2026-02-25 02:00:00.166057', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2cb305dc-796c-4c6d-8ef9-67496dc6dc8d:D-0');
INSERT INTO public.notification_log VALUES ('1931e9c2-e759-4bf0-a4fe-c1b34e6e7c4b', 'f69c0230-b36a-4029-b128-d005743a0efb', '3d04276f-2500-48dc-bf55-6fba3f540baf', 'DEBT', '2cb305dc-796c-4c6d-8ef9-67496dc6dc8d', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-02-25) ครบกำหนดชำระหนี้: สินเชื่อบ้าน ธอส', '2026-02-25 02:00:00.213711', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2cb305dc-796c-4c6d-8ef9-67496dc6dc8d:D-0');
INSERT INTO public.notification_log VALUES ('b178b12a-dfc1-472e-85d9-2b87d9cec52b', 'f69c0230-b36a-4029-b128-d005743a0efb', 'b9416202-5cce-4db4-8024-930f51ed90c8', 'DEBT', '19802574-9ec9-4e44-823b-7b49c1b0783f', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-05): สินเชื่อรถยนต์ Honda City', '2026-03-02 02:00:00.138045', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:19802574-9ec9-4e44-823b-7b49c1b0783f:D-3');
INSERT INTO public.notification_log VALUES ('0b4a7925-153c-4309-a6ba-5ec2e4d34806', 'f69c0230-b36a-4029-b128-d005743a0efb', 'b9416202-5cce-4db4-8024-930f51ed90c8', 'DEBT', '19802574-9ec9-4e44-823b-7b49c1b0783f', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-05): สินเชื่อรถยนต์ Honda City', '2026-03-02 02:00:00.185638', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:19802574-9ec9-4e44-823b-7b49c1b0783f:D-3');
INSERT INTO public.notification_log VALUES ('b68fc1c7-37d2-4d30-8438-4b686de63812', 'f69c0230-b36a-4029-b128-d005743a0efb', 'b9416202-5cce-4db4-8024-930f51ed90c8', 'DEBT', '19802574-9ec9-4e44-823b-7b49c1b0783f', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-05) ครบกำหนดชำระหนี้: สินเชื่อรถยนต์ Honda City', '2026-03-05 02:00:00.128451', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:19802574-9ec9-4e44-823b-7b49c1b0783f:D-0');
INSERT INTO public.notification_log VALUES ('11c810e7-62b5-4245-9183-e9b0926216bf', 'f69c0230-b36a-4029-b128-d005743a0efb', 'b9416202-5cce-4db4-8024-930f51ed90c8', 'DEBT', '19802574-9ec9-4e44-823b-7b49c1b0783f', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-05) ครบกำหนดชำระหนี้: สินเชื่อรถยนต์ Honda City', '2026-03-05 02:00:00.175304', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:19802574-9ec9-4e44-823b-7b49c1b0783f:D-0');
INSERT INTO public.notification_log VALUES ('6eb6b109-d434-4281-80fc-f565f2ee0c3c', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'c074ba84-81a7-418d-849b-4be14a1228a7', 'BUDGET', '7cb75f90-0e37-4658-8b6a-a79022bf7a92', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1222.00 บาท (ใช้ไป 222.20% ของงบทั้งหมด)', '2026-03-29 05:39:51.798849', NULL, NULL);
INSERT INTO public.notification_log VALUES ('1a34315c-0b93-4195-b278-060a9fe17704', '0f43a469-1931-4108-8d76-81f5b8604168', 'e4797e02-2af4-4a4a-bc96-7f65bb86842c', 'DEBT', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-04-05): บัตรเครดิต K-Bank (Platinum)', '2026-04-02 02:00:00.080884', 'Firebase is not initialized. Skipping send.', 'DEBT:7fb2b094-6d5d-473b-880d-2c9fa17baf00:D-3');
INSERT INTO public.notification_log VALUES ('1fde84aa-08b1-443c-97b8-bb1c0ddb10cf', '0f43a469-1931-4108-8d76-81f5b8604168', 'e4797e02-2af4-4a4a-bc96-7f65bb86842c', 'DEBT', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-05) ครบกำหนดชำระหนี้: บัตรเครดิต K-Bank (Platinum)', '2026-04-05 02:00:00.01593', 'Firebase is not initialized. Skipping send.', 'DEBT:7fb2b094-6d5d-473b-880d-2c9fa17baf00:D-0');
INSERT INTO public.notification_log VALUES ('3a49ea82-0ec4-4319-8e89-235b5432e8ea', '0f43a469-1931-4108-8d76-81f5b8604168', 'e4797e02-2af4-4a4a-bc96-7f65bb86842c', 'DEBT', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-05) ครบกำหนดชำระหนี้: บัตรเครดิต K-Bank (Platinum)', '2026-04-05 02:00:00.018826', 'Firebase is not initialized. Skipping send.', 'DEBT:7fb2b094-6d5d-473b-880d-2c9fa17baf00:D-0');
INSERT INTO public.notification_log VALUES ('0d6f59d1-0c7f-449d-b642-a85d79336d51', 'f69c0230-b36a-4029-b128-d005743a0efb', '1792f469-0756-4303-b6a0-48bc7bdeee70', 'DEBT', '5bc6b981-bf44-4edc-a916-bbc76f419e75', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-12): หนี้กยศ.', '2026-03-09 02:00:00.139317', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:5bc6b981-bf44-4edc-a916-bbc76f419e75:D-3');
INSERT INTO public.notification_log VALUES ('4dd095e9-2174-4584-9131-24bd60c7a050', 'f69c0230-b36a-4029-b128-d005743a0efb', '1792f469-0756-4303-b6a0-48bc7bdeee70', 'DEBT', '5bc6b981-bf44-4edc-a916-bbc76f419e75', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-12): หนี้กยศ.', '2026-03-09 02:00:00.189562', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:5bc6b981-bf44-4edc-a916-bbc76f419e75:D-3');
INSERT INTO public.notification_log VALUES ('3faa37e5-dbaa-4e56-a696-f711da44c1fa', 'f69c0230-b36a-4029-b128-d005743a0efb', 'ff7751b1-d6ea-4a93-98b8-c9ff5a17ed52', 'DEBT', '2bc4b142-830f-4bac-830a-4e02665a9a4f', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-25): สินเชื่อ CIMB', '2026-03-22 02:00:00.130403', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2bc4b142-830f-4bac-830a-4e02665a9a4f:D-3');
INSERT INTO public.notification_log VALUES ('3723f428-9965-4a04-a62c-ed2e8cf41d85', 'f69c0230-b36a-4029-b128-d005743a0efb', 'ff7751b1-d6ea-4a93-98b8-c9ff5a17ed52', 'DEBT', '2bc4b142-830f-4bac-830a-4e02665a9a4f', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-25): สินเชื่อ CIMB', '2026-03-22 02:00:00.174155', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2bc4b142-830f-4bac-830a-4e02665a9a4f:D-3');
INSERT INTO public.notification_log VALUES ('96efc299-bd76-4373-b892-728f3a1e1fdc', 'f69c0230-b36a-4029-b128-d005743a0efb', 'ff7751b1-d6ea-4a93-98b8-c9ff5a17ed52', 'DEBT', '2bc4b142-830f-4bac-830a-4e02665a9a4f', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-25) ครบกำหนดชำระหนี้: สินเชื่อ CIMB', '2026-03-25 02:00:00.13498', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2bc4b142-830f-4bac-830a-4e02665a9a4f:D-0');
INSERT INTO public.notification_log VALUES ('c6702b0a-ba21-4b75-8ef5-abaa6dcf82a1', 'f69c0230-b36a-4029-b128-d005743a0efb', 'ff7751b1-d6ea-4a93-98b8-c9ff5a17ed52', 'DEBT', '2bc4b142-830f-4bac-830a-4e02665a9a4f', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-25) ครบกำหนดชำระหนี้: สินเชื่อ CIMB', '2026-03-25 02:00:00.184564', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:2bc4b142-830f-4bac-830a-4e02665a9a4f:D-0');
INSERT INTO public.notification_log VALUES ('39abd92c-05f9-4391-917c-b9e6af152f1d', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '65ec6c0b-3b02-4782-994d-8de62ccbcfff', 'DEBT', '8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-30): 444', '2026-03-27 02:00:00.13027', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106:D-3');
INSERT INTO public.notification_log VALUES ('d19f97a9-1c9d-4261-aa3e-a213952f117e', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '65ec6c0b-3b02-4782-994d-8de62ccbcfff', 'DEBT', '8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-30): 444', '2026-03-27 02:00:00.177027', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106:D-3');
INSERT INTO public.notification_log VALUES ('089560f8-536b-46ff-a2f8-038e75bb729b', '0f43a469-1931-4108-8d76-81f5b8604168', '4cd66ade-a637-4329-b33d-0dcda3c7f4c3', 'BUDGET', 'af8396f9-1327-4260-9aab-c03defcf708d', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 19000.00 บาท (ใช้ไป 2000.00% ของงบทั้งหมด)', '2026-03-26 20:28:03.206008', NULL, NULL);
INSERT INTO public.notification_log VALUES ('b399e460-0afa-4be4-aaae-83551411dc4c', 'f69c0230-b36a-4029-b128-d005743a0efb', '1792f469-0756-4303-b6a0-48bc7bdeee70', 'DEBT', '5bc6b981-bf44-4edc-a916-bbc76f419e75', 'PUSH', 'CLICKED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-12): หนี้กยศ.', '2026-03-09 02:00:00.191528', NULL, 'DEBT:5bc6b981-bf44-4edc-a916-bbc76f419e75:D-3');
INSERT INTO public.notification_log VALUES ('509d1e62-92ab-440f-b08e-0417792142dc', 'f69c0230-b36a-4029-b128-d005743a0efb', 'ff7751b1-d6ea-4a93-98b8-c9ff5a17ed52', 'DEBT', '2bc4b142-830f-4bac-830a-4e02665a9a4f', 'PUSH', 'CLICKED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-25): สินเชื่อ CIMB', '2026-03-22 02:00:00.175816', NULL, 'DEBT:2bc4b142-830f-4bac-830a-4e02665a9a4f:D-3');
INSERT INTO public.notification_log VALUES ('eba34358-63fd-47fe-80ce-82e29f4c8fd7', 'f69c0230-b36a-4029-b128-d005743a0efb', 'ff7751b1-d6ea-4a93-98b8-c9ff5a17ed52', 'DEBT', '2bc4b142-830f-4bac-830a-4e02665a9a4f', 'PUSH', 'CLICKED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-25) ครบกำหนดชำระหนี้: สินเชื่อ CIMB', '2026-03-25 02:00:00.186445', NULL, 'DEBT:2bc4b142-830f-4bac-830a-4e02665a9a4f:D-0');
INSERT INTO public.notification_log VALUES ('9636b952-edb2-428e-8bfe-9f27596a2f16', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.125604', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('3229eda8-e5b5-4658-8de8-2bde0cc522ca', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.127249', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('3078e9a0-308b-459f-8214-dd58ced9b862', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.128721', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('54fc8112-517b-464e-983c-87a279e0db78', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '65ec6c0b-3b02-4782-994d-8de62ccbcfff', 'DEBT', '8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-30): 444', '2026-03-27 02:00:00.218948', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106:D-3');
INSERT INTO public.notification_log VALUES ('43c94e6a-453c-4b7b-9be6-e461659de015', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '65ec6c0b-3b02-4782-994d-8de62ccbcfff', 'DEBT', '8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-30): 444', '2026-03-27 02:00:00.281268', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106:D-3');
INSERT INTO public.notification_log VALUES ('a8304ec4-de9b-4769-afdd-e573d886212d', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '65ec6c0b-3b02-4782-994d-8de62ccbcfff', 'DEBT', '8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-30): 444', '2026-03-27 02:00:00.321532', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106:D-3');
INSERT INTO public.notification_log VALUES ('8ea42fdd-5e62-4dae-8fc4-6782c4c952fd', '0f43a469-1931-4108-8d76-81f5b8604168', '7684f75a-4ac6-4a25-91b9-e84e7f216b31', 'BUDGET', '844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 0.00 บาท (ใช้ไป 100.00% ของงบทั้งหมด)', '2026-03-26 21:06:58.873903', NULL, NULL);
INSERT INTO public.notification_log VALUES ('01ccdf0f-7a57-469b-a2df-63ae3cdfa0ea', '0f43a469-1931-4108-8d76-81f5b8604168', '58a7a16a-523d-43fe-ad21-197f6c666a94', 'BUDGET', '844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 150.00 บาท (ใช้ไป 103.00% ของงบทั้งหมด)', '2026-03-27 01:03:15.395564', NULL, NULL);
INSERT INTO public.notification_log VALUES ('b47cfe8a-bf22-4793-9b1f-4615ec9e40b5', '0f43a469-1931-4108-8d76-81f5b8604168', 'b08dc031-3cb7-485f-b8fa-969a9cb52232', 'BUDGET', '844f6cbd-99b1-4ff2-83d2-1171bf8d7e64', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 300.00 บาท (ใช้ไป 106.00% ของงบทั้งหมด)', '2026-03-27 15:17:20.275968', NULL, NULL);
INSERT INTO public.notification_log VALUES ('c67b5001-def0-4318-bb41-d81e80dbefc0', '0f43a469-1931-4108-8d76-81f5b8604168', '810ebd0b-26bc-41a3-bc78-cd1306afb775', 'BUDGET', 'af8396f9-1327-4260-9aab-c03defcf708d', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 19035.00 บาท (ใช้ไป 2003.50% ของงบทั้งหมด)', '2026-03-27 17:06:59.433706', NULL, NULL);
INSERT INTO public.notification_log VALUES ('c8f15f6f-1c68-4a69-9cfe-2674504aa0e9', '0f43a469-1931-4108-8d76-81f5b8604168', '244ca635-12ad-4017-a26a-e3d1b518b463', 'BUDGET', 'af8396f9-1327-4260-9aab-c03defcf708d', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 19105.00 บาท (ใช้ไป 2010.50% ของงบทั้งหมด)', '2026-03-27 17:34:25.562904', NULL, NULL);
INSERT INTO public.notification_log VALUES ('72395e77-55ce-42e0-87ee-33bd37269aa3', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', '7d057e9b-63c2-4c61-8ece-4c282a63e316', 'BUDGET', '7cb75f90-0e37-4658-8b6a-a79022bf7a92', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 2232.00 บาท (ใช้ไป 323.20% ของงบทั้งหมด)', '2026-03-29 05:19:09.354189', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('41bb0758-169e-47f9-bcde-08588f4de46b', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', '69162486-d0f4-4dbb-a397-e4cfe7c82d00', 'BUDGET', '7cb75f90-0e37-4658-8b6a-a79022bf7a92', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 111.00 บาท (ใช้ไป 111.10% ของงบทั้งหมด)', '2026-03-29 05:38:06.348608', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('d805ece9-6281-420f-92a8-9944a0b5f672', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'c074ba84-81a7-418d-849b-4be14a1228a7', 'BUDGET', '7cb75f90-0e37-4658-8b6a-a79022bf7a92', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1222.00 บาท (ใช้ไป 222.20% ของงบทั้งหมด)', '2026-03-29 05:39:51.760782', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('97cdc008-6d06-4594-a4ec-2369b1aae454', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', '7d057e9b-63c2-4c61-8ece-4c282a63e316', 'BUDGET', '7cb75f90-0e37-4658-8b6a-a79022bf7a92', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 2232.00 บาท (ใช้ไป 323.20% ของงบทั้งหมด)', '2026-03-29 05:19:09.381383', NULL, NULL);
INSERT INTO public.notification_log VALUES ('ad6615e7-dace-4dd0-ad86-57d7cfc36e46', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', '69162486-d0f4-4dbb-a397-e4cfe7c82d00', 'BUDGET', '7cb75f90-0e37-4658-8b6a-a79022bf7a92', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 111.00 บาท (ใช้ไป 111.10% ของงบทั้งหมด)', '2026-03-29 05:38:06.384942', NULL, NULL);
INSERT INTO public.notification_log VALUES ('8275062e-5be9-4209-a80f-9b4647d7ed42', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '65ec6c0b-3b02-4782-994d-8de62ccbcfff', 'DEBT', '8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106', 'PUSH', 'CLICKED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-30): 444', '2026-03-27 02:00:00.32757', NULL, 'DEBT:8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106:D-3');
INSERT INTO public.notification_log VALUES ('a3d733e6-62d3-4750-b773-4b3ce5c8618f', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '0e4acd0e-1b5b-46f4-b5bb-08b5319ca88f', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 4000.00 บาท (ใช้ไป 500.00% ของงบทั้งหมด)', '2026-03-29 20:26:50.802693', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('58c766df-a2ec-43b8-88b3-42e1a734b6a2', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '0e4acd0e-1b5b-46f4-b5bb-08b5319ca88f', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 4000.00 บาท (ใช้ไป 500.00% ของงบทั้งหมด)', '2026-03-29 20:26:50.87418', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('d5578171-398e-4f5d-b756-5b58fb43cfdc', '0f43a469-1931-4108-8d76-81f5b8604168', 'e4797e02-2af4-4a4a-bc96-7f65bb86842c', 'DEBT', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PUSH', 'CLICKED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-05) ครบกำหนดชำระหนี้: บัตรเครดิต K-Bank (Platinum)', '2026-04-05 02:00:00.021034', NULL, 'DEBT:7fb2b094-6d5d-473b-880d-2c9fa17baf00:D-0');
INSERT INTO public.notification_log VALUES ('fef11867-0a35-478f-bcf0-d2a0857771fa', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '0e4acd0e-1b5b-46f4-b5bb-08b5319ca88f', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 4000.00 บาท (ใช้ไป 500.00% ของงบทั้งหมด)', '2026-03-29 20:26:50.953258', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('50d8ba84-ca6c-437a-b486-61e2b3c0bf04', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '0e4acd0e-1b5b-46f4-b5bb-08b5319ca88f', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 4000.00 บาท (ใช้ไป 500.00% ของงบทั้งหมด)', '2026-03-29 20:26:51.028725', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('198cd942-fac5-4034-bdc7-1334ed9dfc7a', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '0e4acd0e-1b5b-46f4-b5bb-08b5319ca88f', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 4000.00 บาท (ใช้ไป 500.00% ของงบทั้งหมด)', '2026-03-29 20:26:51.106575', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('4adf8a9b-5228-4453-a195-2dae56487c27', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd8227f94-63ab-49b6-a3ae-8beb488ac7c3', 'BUDGET', '751fee63-db79-48f3-9177-fb4ce1368f47', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-29 20:27:35.531834', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('84077e9e-042f-4755-a22b-3e4ec079f43f', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd8227f94-63ab-49b6-a3ae-8beb488ac7c3', 'BUDGET', '751fee63-db79-48f3-9177-fb4ce1368f47', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-29 20:27:35.607938', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('cf5ca856-a08e-40ab-a426-9ca50517d037', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd8227f94-63ab-49b6-a3ae-8beb488ac7c3', 'BUDGET', '751fee63-db79-48f3-9177-fb4ce1368f47', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-29 20:27:35.680932', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('92b508c8-efba-4300-aceb-01bf2245503f', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd8227f94-63ab-49b6-a3ae-8beb488ac7c3', 'BUDGET', '751fee63-db79-48f3-9177-fb4ce1368f47', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-29 20:27:35.757665', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('93ba079d-60c0-4288-9adc-851b6eae7e87', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd8227f94-63ab-49b6-a3ae-8beb488ac7c3', 'BUDGET', '751fee63-db79-48f3-9177-fb4ce1368f47', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-29 20:27:35.833875', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('e668594e-e2ce-4dcb-acd8-5e6a59957847', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '0e4acd0e-1b5b-46f4-b5bb-08b5319ca88f', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 4000.00 บาท (ใช้ไป 500.00% ของงบทั้งหมด)', '2026-03-29 20:26:51.118943', NULL, NULL);
INSERT INTO public.notification_log VALUES ('693d2a31-d4c5-488f-9e8a-0ddcd58bb1d8', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd8227f94-63ab-49b6-a3ae-8beb488ac7c3', 'BUDGET', '751fee63-db79-48f3-9177-fb4ce1368f47', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-29 20:27:35.843271', NULL, NULL);
INSERT INTO public.notification_log VALUES ('439629a1-01bc-4e5a-87ca-71a452aed66a', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'b2471a53-b9cb-4a24-973d-9d38428f0482', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', '2026-03-30 00:14:42.83469', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('15ccd8ad-c311-477b-92ef-129442911592', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.130468', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('fc1f35f4-0314-4552-b851-99e5ffab2f8c', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'b2471a53-b9cb-4a24-973d-9d38428f0482', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', '2026-03-30 00:14:42.903934', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('137e80c7-4848-4e81-a877-595f8fe4c34c', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'b2471a53-b9cb-4a24-973d-9d38428f0482', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', '2026-03-30 00:14:42.983114', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('8100da47-8a72-4e37-9ec5-240c1cad8e17', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'b2471a53-b9cb-4a24-973d-9d38428f0482', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', '2026-03-30 00:14:43.062006', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('0144aed2-fd5d-45e1-8d1b-27f237e494d5', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'b2471a53-b9cb-4a24-973d-9d38428f0482', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', '2026-03-30 00:14:43.134762', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('77384fc4-12b8-463d-9e95-e7718ebd1278', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'b2471a53-b9cb-4a24-973d-9d38428f0482', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', '2026-03-30 00:14:43.199519', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('b6f327f3-c87b-4eca-811e-fd40bab5d5a6', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'b2471a53-b9cb-4a24-973d-9d38428f0482', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', '2026-03-30 00:14:43.209144', NULL, NULL);
INSERT INTO public.notification_log VALUES ('e8d0f268-92f6-4fe8-85a1-0e5f7d3e5179', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:12.709735', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('bc1ae50c-0be4-4871-914e-9b6744b20c10', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:12.774921', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('02a4b1ec-4eec-4bd6-8c5e-ce7cb23be58b', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:12.856981', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('bd30376f-ebf4-40a7-a4ed-a9836e1ef760', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:12.931986', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('8e5fb5e9-ffe1-423a-9ca6-d6c3126d67a5', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:13.007013', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('5bc888af-99d6-4f2f-93cd-f48f0ad2d7f6', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.131708', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('ff003cf2-e2ae-4d8a-ab02-03d139123d1b', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.133519', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('eff0bdb0-5390-4c13-adb5-0054b3514e14', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:13.082658', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('faa7c09d-a6c6-4f33-bb10-638d08e31def', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:13.142069', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('50b79be8-b15c-4a45-993b-2a471b57fc84', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', 'BUDGET', '10ae6acb-5d10-4b9c-bab9-ee0714cc7e02', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', '2026-03-30 00:49:13.149588', NULL, NULL);
INSERT INTO public.notification_log VALUES ('f013c524-de78-4eb6-844a-d0c175c1df04', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.421835', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('2d0420a0-2017-4879-9d3e-0c1d7055fd08', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.484412', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('ff9b92fe-c3e0-4b67-a842-94cbdc5bf7fb', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.534103', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('2584f073-0ac6-4987-a08f-25efef4d12ae', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.580451', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('9befebd8-ff04-447d-b993-d86c70871053', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.62685', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('ac618e20-4d3f-434e-9516-6f3feee8263a', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.672558', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('f0c161f5-7e56-4f3b-be45-6b91da036dca', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.719855', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('944932c8-f29a-4305-a8fe-c1b39c96cd43', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.76678', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('e6cab982-47df-4d80-abeb-af0c3050b258', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.139204', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('60b656ab-37a4-4c42-bf1d-68b84bfdc66b', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.140232', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('1ce94188-d692-4a51-9e2c-dbb6bfb86471', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.811061', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('f4049873-840b-476a-8b6a-d9d61c8c7b3e', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.857302', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('bdbd97ea-f69a-46d5-b59e-0517d862b126', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '404374a0-2b9b-492e-962d-2c8edb78027a', 'BUDGET', '28ffa0bf-87d2-40fc-b2a3-bffdaf2b19c4', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', '2026-03-29 19:02:50.860612', NULL, NULL);
INSERT INTO public.notification_log VALUES ('516a51e6-2cbb-4869-8bc4-eaeed1bbe8ac', '9db8aa73-7870-4481-a109-6430ca921dd5', '39e6367f-93f4-4b3b-9d8b-1f8052acb3d1', 'BUDGET', 'bfc856fa-f166-4695-9075-c8f1c736216c', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1323.00 บาท (ใช้ไป 232.30% ของงบทั้งหมด)', '2026-03-29 21:29:53.973171', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('c445d76b-7504-4243-ab54-d06b34c76eb6', '9db8aa73-7870-4481-a109-6430ca921dd5', '39e6367f-93f4-4b3b-9d8b-1f8052acb3d1', 'BUDGET', 'bfc856fa-f166-4695-9075-c8f1c736216c', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1323.00 บาท (ใช้ไป 232.30% ของงบทั้งหมด)', '2026-03-29 21:29:54.026626', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('0f1d4462-3fd5-49d1-9ccc-c829489329c8', '9db8aa73-7870-4481-a109-6430ca921dd5', '39e6367f-93f4-4b3b-9d8b-1f8052acb3d1', 'BUDGET', 'bfc856fa-f166-4695-9075-c8f1c736216c', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1323.00 บาท (ใช้ไป 232.30% ของงบทั้งหมด)', '2026-03-29 21:29:54.084251', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('d216b90f-1cba-4fb9-8675-cbc5e8f1594a', 'f69c0230-b36a-4029-b128-d005743a0efb', '3d04276f-2500-48dc-bf55-6fba3f540baf', 'DEBT', '2cb305dc-796c-4c6d-8ef9-67496dc6dc8d', 'PUSH', 'CLICKED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-02-25): สินเชื่อบ้าน ธอส', '2026-02-22 02:00:00.296517', NULL, 'DEBT:2cb305dc-796c-4c6d-8ef9-67496dc6dc8d:D-3');
INSERT INTO public.notification_log VALUES ('9911d91f-eee1-4481-af10-6bf77b3911c2', 'f69c0230-b36a-4029-b128-d005743a0efb', '3d04276f-2500-48dc-bf55-6fba3f540baf', 'DEBT', '2cb305dc-796c-4c6d-8ef9-67496dc6dc8d', 'PUSH', 'CLICKED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-02-25) ครบกำหนดชำระหนี้: สินเชื่อบ้าน ธอส', '2026-02-25 02:00:00.215885', NULL, 'DEBT:2cb305dc-796c-4c6d-8ef9-67496dc6dc8d:D-0');
INSERT INTO public.notification_log VALUES ('1e4ff63f-6ad7-458a-9308-d4d55cdeea15', 'f69c0230-b36a-4029-b128-d005743a0efb', 'b9416202-5cce-4db4-8024-930f51ed90c8', 'DEBT', '19802574-9ec9-4e44-823b-7b49c1b0783f', 'PUSH', 'CLICKED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-03-05): สินเชื่อรถยนต์ Honda City', '2026-03-02 02:00:00.187658', NULL, 'DEBT:19802574-9ec9-4e44-823b-7b49c1b0783f:D-3');
INSERT INTO public.notification_log VALUES ('9b02cb48-1c7a-4e7a-84b3-73f527eb4c5c', 'f69c0230-b36a-4029-b128-d005743a0efb', 'b9416202-5cce-4db4-8024-930f51ed90c8', 'DEBT', '19802574-9ec9-4e44-823b-7b49c1b0783f', 'PUSH', 'CLICKED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-05) ครบกำหนดชำระหนี้: สินเชื่อรถยนต์ Honda City', '2026-03-05 02:00:00.177137', NULL, 'DEBT:19802574-9ec9-4e44-823b-7b49c1b0783f:D-0');
INSERT INTO public.notification_log VALUES ('3eb2af3e-7ec8-4f56-b397-4f3fbaf90fe2', '0f43a469-1931-4108-8d76-81f5b8604168', 'f16b2838-989e-4102-91c0-376d02d6ff3b', 'DEBT', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-30) ครบกำหนดชำระหนี้: กู้เงินนอกระบบ (เฮียเจี้ยง)', '2026-03-30 02:00:00.132156', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:359c74d3-1071-4b95-95f7-b7d655bdf4a5:D-0');
INSERT INTO public.notification_log VALUES ('c721922b-227e-4018-b1ab-fc454914ffed', '0f43a469-1931-4108-8d76-81f5b8604168', 'f16b2838-989e-4102-91c0-376d02d6ff3b', 'DEBT', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-30) ครบกำหนดชำระหนี้: กู้เงินนอกระบบ (เฮียเจี้ยง)', '2026-03-30 02:00:00.186095', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', 'DEBT:359c74d3-1071-4b95-95f7-b7d655bdf4a5:D-0');
INSERT INTO public.notification_log VALUES ('fd445838-dd1c-4c9a-8b2e-4893c25cc15a', '9db8aa73-7870-4481-a109-6430ca921dd5', '39e6367f-93f4-4b3b-9d8b-1f8052acb3d1', 'BUDGET', 'bfc856fa-f166-4695-9075-c8f1c736216c', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1323.00 บาท (ใช้ไป 232.30% ของงบทั้งหมด)', '2026-03-29 21:29:54.086668', NULL, NULL);
INSERT INTO public.notification_log VALUES ('130e105d-254d-44df-98c6-d126c2ebfb17', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'SENT', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.141538', NULL, 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('b836a0f4-ca03-485e-b575-4ce0810b74f9', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:36.693953', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('954af27e-a252-49d9-9627-3145880e3347', '0f43a469-1931-4108-8d76-81f5b8604168', '4e3725b0-60c0-414c-8225-f76f7c614076', 'BUDGET', '80697d4a-b27a-42bc-aa3a-08d8f69a3ca8', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 20.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-04-27 06:13:44.701415', 'Firebase is not initialized. Skipping send.', NULL);
INSERT INTO public.notification_log VALUES ('55858947-00ac-470f-a192-c8384dbd3959', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:36.743112', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('f9ea1b87-3cfe-427d-bb85-327cb02c1de1', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:36.792541', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('c7335564-07b8-4e42-a8a3-5df912107fe1', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:36.837225', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('89bca68d-85c5-43a0-908c-5cc36a51ef75', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:36.891175', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('b004a292-2c04-4dc9-9296-4bfa3e088f6d', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:36.942653', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('bbcf3079-0f6b-4dc4-abcc-88edd1f86945', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:36.988307', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('ac33b65b-7eb9-4f53-9328-43c702983827', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:37.035358', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('511909c2-0cef-4034-a41f-ce9455f51f8f', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:37.078466', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('5651c3c7-6007-4d56-b69d-f426d83ae320', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.4526', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('65fe8ec3-5d74-473c-8294-b4782089947d', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.452786', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('644e74cd-f2c1-4914-a88d-b52d591093fa', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.45288', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('df7dc6a4-0aa0-4bbc-8bac-c9ddd51f0902', '0f43a469-1931-4108-8d76-81f5b8604168', '4e3725b0-60c0-414c-8225-f76f7c614076', 'BUDGET', '80697d4a-b27a-42bc-aa3a-08d8f69a3ca8', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 20.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-04-27 06:13:44.70567', 'Firebase is not initialized. Skipping send.', NULL);
INSERT INTO public.notification_log VALUES ('6aaa79e9-68c0-4c0b-bb71-12b7717d7096', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.45302', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('b11fa013-09e1-46f2-b8a1-ccface9e15ab', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.453096', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('861da45f-26c4-46ce-b8af-dca46e96bdb6', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.453202', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('c25f50f0-c333-425d-9383-23cfa5660212', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.453261', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('abbc4142-67d7-4238-acf7-1cb96382ec9a', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.453317', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('1855eb34-ee4b-4a3d-b00a-13d501e98658', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.453373', 'Unknown error while making a remote service call: Error getting access token for service account: 400 Bad Request
POST https://oauth2.googleapis.com/token
{"error":"invalid_grant","error_description":"Invalid JWT Signature."}, iss: firebase-adminsdk-fbsvc@financecare-bca58.iam.gserviceaccount.com', NULL);
INSERT INTO public.notification_log VALUES ('bcb97a0f-dfad-4e3d-ae8a-95b212ec210b', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'f038ed75-4448-4eaf-a883-561363b5da13', 'BUDGET', 'c17c90a3-b75e-453d-a9d8-aeecf18a9d5a', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:48:37.080194', NULL, NULL);
INSERT INTO public.notification_log VALUES ('4431793f-4fc8-416c-bc55-23af4f62cec8', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd2ab945c-491d-4531-84fd-8a1f73f56184', 'BUDGET', '6a74c673-886c-4e65-8c96-0635bf0f6eb9', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-03-30 05:51:14.453428', NULL, NULL);
INSERT INTO public.notification_log VALUES ('43e38a2b-366f-4a5f-a391-7cf43c9ec552', '0f43a469-1931-4108-8d76-81f5b8604168', 'e93b9b96-bc59-4e73-b2e8-5f2a3748df86', 'DEBT', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: สินเชื่อบุคคล UOB i-Cash', '2026-04-01 02:00:00.092622', 'Firebase is not initialized. Skipping send.', 'DEBT:fc81d7f6-2120-4524-b575-f82c2f6bc80e:D-0');
INSERT INTO public.notification_log VALUES ('2a3fa201-15e6-486d-9bba-b3dd5dc08c86', '0f43a469-1931-4108-8d76-81f5b8604168', 'e93b9b96-bc59-4e73-b2e8-5f2a3748df86', 'DEBT', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: สินเชื่อบุคคล UOB i-Cash', '2026-04-01 02:00:00.097582', 'Firebase is not initialized. Skipping send.', 'DEBT:fc81d7f6-2120-4524-b575-f82c2f6bc80e:D-0');
INSERT INTO public.notification_log VALUES ('ddc05da3-f3a4-4b73-bf95-8b034700b102', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.121681', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('9830bf06-c2f0-46a8-8e7d-8de5f41aaccf', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-04-01) ครบกำหนดชำระหนี้: rrrr', '2026-04-01 02:00:00.124039', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('45662690-5a5a-4104-846f-0ef96d1c72fb', '0f43a469-1931-4108-8d76-81f5b8604168', 'e4797e02-2af4-4a4a-bc96-7f65bb86842c', 'DEBT', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PUSH', 'FAILED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-04-05): บัตรเครดิต K-Bank (Platinum)', '2026-04-02 02:00:00.076247', 'Firebase is not initialized. Skipping send.', 'DEBT:7fb2b094-6d5d-473b-880d-2c9fa17baf00:D-3');
INSERT INTO public.notification_log VALUES ('5c4846cf-2b14-4f88-b647-c531e4444f5b', '0f43a469-1931-4108-8d76-81f5b8604168', 'e4797e02-2af4-4a4a-bc96-7f65bb86842c', 'DEBT', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'PUSH', 'CLICKED', 'เตือนหนี้ใกล้ครบกำหนด', 'อีก 3 วัน จะครบกำหนดชำระหนี้ (2026-04-05): บัตรเครดิต K-Bank (Platinum)', '2026-04-02 02:00:00.09109', NULL, 'DEBT:7fb2b094-6d5d-473b-880d-2c9fa17baf00:D-3');
INSERT INTO public.notification_log VALUES ('110817f1-a7c3-4035-aa15-9a2051569078', '0f43a469-1931-4108-8d76-81f5b8604168', 'f16b2838-989e-4102-91c0-376d02d6ff3b', 'DEBT', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'PUSH', 'CLICKED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-03-30) ครบกำหนดชำระหนี้: กู้เงินนอกระบบ (เฮียเจี้ยง)', '2026-03-30 02:00:00.187603', NULL, 'DEBT:359c74d3-1071-4b95-95f7-b7d655bdf4a5:D-0');
INSERT INTO public.notification_log VALUES ('1c61526c-74c3-496a-97b6-c3586a7f155c', '0f43a469-1931-4108-8d76-81f5b8604168', '4e3725b0-60c0-414c-8225-f76f7c614076', 'BUDGET', '80697d4a-b27a-42bc-aa3a-08d8f69a3ca8', 'PUSH', 'FAILED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 20.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-04-27 06:13:44.707314', 'Firebase is not initialized. Skipping send.', NULL);
INSERT INTO public.notification_log VALUES ('0abed065-b5d9-45c5-bf51-f063a0ffc7d4', '0f43a469-1931-4108-8d76-81f5b8604168', '4e3725b0-60c0-414c-8225-f76f7c614076', 'BUDGET', '80697d4a-b27a-42bc-aa3a-08d8f69a3ca8', 'PUSH', 'CLICKED', 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 20.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', '2026-04-27 06:13:44.709083', NULL, NULL);
INSERT INTO public.notification_log VALUES ('3e69d2a5-6a5b-4172-8602-69143d8707f2', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.023764', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('ab758a1c-1c02-4716-92db-05e88f8e6130', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.025859', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('572db8bf-cac8-4c83-8f0d-55294495f277', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.029678', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('aa612bf3-c3c2-4607-a454-bbcebc7bcb47', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.031512', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('84cdc200-59c1-4665-b62b-14f3532dcd3c', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.035387', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('a62d08dc-44ca-4b84-9b0f-b7e15dc04652', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.036676', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('f202c4c2-a325-4e17-97be-7f7d48f5cab8', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.037943', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('3a6c92d7-275a-41c0-95e0-7f8dc72dd82e', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.039581', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('b7559789-8344-4fbc-b882-3b7d0b84cebd', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.041021', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('6f58b465-01ae-43b8-90b3-433722f4c92f', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'FAILED', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.042438', 'Firebase is not initialized. Skipping send.', 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');
INSERT INTO public.notification_log VALUES ('e65bc96c-09d5-41ea-a606-d8be07ac8961', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', '998b0938-3ffe-4491-b531-905f671ce8ee', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'PUSH', 'SENT', 'วันนี้ครบกำหนดชำระหนี้', 'วันนี้ (2026-05-01) ครบกำหนดชำระหนี้: rrrr', '2026-05-01 02:00:00.043915', NULL, 'DEBT:c7157984-89d3-48ae-a619-84a4890f7a60:D-0');


--
-- TOC entry 3597 (class 0 OID 16913)
-- Dependencies: 226
-- Data for Name: notification_rule; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.notification_rule VALUES ('bf29c9df-9e66-4321-8b15-30c387d2ca25', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '4e0eddc5-4a40-4f05-bb0a-94eb987887b5', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต SCB Platinum จำนวนขั้นต่ำ 3000.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 13:59:46.299798', '2026-02-16 13:59:46.299798');
INSERT INTO public.notification_rule VALUES ('b9416202-5cce-4db4-8024-930f51ed90c8', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '19802574-9ec9-4e44-823b-7b49c1b0783f', 'เตือนหนี้ครบกำหนด', 'หนี้ สินเชื่อรถยนต์ Honda City จำนวนขั้นต่ำ 8200.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 14:01:49.033329', '2026-02-16 14:01:49.033329');
INSERT INTO public.notification_rule VALUES ('c4f10eeb-b335-4648-9535-1c4a7616b499', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', 'e5c0153f-c61f-4d71-ada3-ad6dbad8f170', 'เตือนหนี้ครบกำหนด', 'หนี้ ยืมเงินคุณต้น จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 14:04:08.520159', '2026-02-16 14:04:08.520159');
INSERT INTO public.notification_rule VALUES ('5cf4ba4a-ef84-4c5e-9795-0916d91d955b', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '0e5d2920-7ec5-4ecf-b033-cce5eee9f434', 'เตือนหนี้ครบกำหนด', 'หนี้ 343434 จำนวนขั้นต่ำ 233.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 07:06:50.242901', '2026-02-16 07:06:50.242913');
INSERT INTO public.notification_rule VALUES ('107f435c-3fe6-4987-97af-9ca12ed79221', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', 'f3be9a88-2be3-431a-b0a4-01adb2d21322', 'เตือนหนี้ครบกำหนด', 'หนี้ เงินกู้ร้านกาแฟ จำนวนขั้นต่ำ 12000.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 14:18:04.224802', '2026-02-16 14:18:04.224802');
INSERT INTO public.notification_rule VALUES ('3d04276f-2500-48dc-bf55-6fba3f540baf', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '2cb305dc-796c-4c6d-8ef9-67496dc6dc8d', 'เตือนหนี้ครบกำหนด', 'หนี้ สินเชื่อบ้าน ธอส จำนวนขั้นต่ำ 18500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 14:22:48.735929', '2026-02-16 14:22:48.735929');
INSERT INTO public.notification_rule VALUES ('75c40257-6e8e-4bd6-a8f9-e2487ef8f9fc', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '80c0131b-bdd3-43d0-8da3-eb8df303fa98', 'เตือนหนี้ครบกำหนด', 'หนี้ พสพส จำนวนขั้นต่ำ 2356.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 09:07:45.697189', '2026-02-16 09:07:45.697333');
INSERT INTO public.notification_rule VALUES ('f850e835-8bb4-49b3-b242-502671a3aa9f', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'f121057d-4099-4c8b-9453-4bf04fe945da', 'เตือนหนี้ครบกำหนด', 'หนี้ ◌ากากา จำนวนขั้นต่ำ 111.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 09:15:34.530632', '2026-02-16 09:15:34.530646');
INSERT INTO public.notification_rule VALUES ('0990dee6-dad7-4460-b7e7-26d0b34c60b8', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', 'd9b1f537-e78a-48f3-a7e5-9f4efc5c4f28', 'เตือนหนี้ครบกำหนด', 'หนี้ kksk จำนวนขั้นต่ำ 150.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 12:13:51.635103', '2026-02-16 12:13:51.635116');
INSERT INTO public.notification_rule VALUES ('2258bd11-1133-4531-a7ce-d4a06df64859', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '6f4c123e-aa56-4c4e-b60e-f63bfb887f5e', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้กยศ. จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 12:17:24.492313', '2026-02-16 12:17:24.492325');
INSERT INTO public.notification_rule VALUES ('a3f6fd6a-668e-4817-bc56-a725f8da2582', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '5e60776c-04d1-4dfd-bb48-522450e3e5c7', 'เตือนหนี้ครบกำหนด', 'หนี้ กยศ. จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 12:23:27.44938', '2026-02-16 12:23:27.449393');
INSERT INTO public.notification_rule VALUES ('8fda1941-0175-47f0-84d9-278459da2072', 'f69c0230-b36a-4029-b128-d005743a0efb', 'BUDGET', NULL, 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Bills คงเหลือ 50.0 บาท (95.00% ของงบประมาณทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 12:24:15.220877', '2026-02-16 12:24:15.220892');
INSERT INTO public.notification_rule VALUES ('81287fb5-13bf-48a9-8765-bc7d746c2f8d', 'f69c0230-b36a-4029-b128-d005743a0efb', 'BUDGET', NULL, 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Food คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 12:25:08.928982', '2026-02-16 12:25:08.928993');
INSERT INTO public.notification_rule VALUES ('06ee6a4a-d527-4ec3-a98e-6e47aac23233', 'f69c0230-b36a-4029-b128-d005743a0efb', 'BUDGET', NULL, 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Entertainment คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 12:26:25.839146', '2026-02-16 12:26:25.839157');
INSERT INTO public.notification_rule VALUES ('c9d768ae-0f07-4522-97d8-99000356eac6', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '07129ae0-9007-4688-977a-5247a449102e', 'เตือนหนี้ครบกำหนด', 'หนี้ กยศ. จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 12:27:55.832187', '2026-02-16 12:27:55.832202');
INSERT INTO public.notification_rule VALUES ('5d9ca599-b4d8-40ca-a3a6-84ff3f89add5', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', 'dbfade41-a6f8-41de-a0e0-1528891eb5fd', 'เตือนหนี้ครบกำหนด', 'หนี้ กยศ. จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-16 12:32:30.697566', '2026-02-16 12:32:30.697579');
INSERT INTO public.notification_rule VALUES ('e8d520da-5dc2-4136-967a-6344e52af5f4', 'f69c0230-b36a-4029-b128-d005743a0efb', 'BUDGET', NULL, 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Saving คงเหลือ 50.0 บาท (95.00% ของงบประมาณทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 12:34:26.827471', '2026-02-16 12:34:26.827488');
INSERT INTO public.notification_rule VALUES ('4fed1521-f180-4a62-83be-5dfca57bf2b4', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณใกล้ครบกำหนด', 'หมวด Bills เหลืองบประมาณ 160.00 บาท (ใช้ไปแล้ว 92.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 23:40:14.771958', '2026-02-16 23:40:14.771958');
INSERT INTO public.notification_rule VALUES ('ce30b449-cf1d-46cc-9996-ad8b5772e1c2', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณใกล้ครบกำหนด', 'หมวด Bills เหลืองบประมาณ 60.00 บาท (ใช้ไปแล้ว 97.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 23:40:31.336668', '2026-02-16 23:40:31.336668');
INSERT INTO public.notification_rule VALUES ('cba7aa47-3672-44b9-8b3c-ef242860a2fc', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 40.00 บาท (ใช้ไป 102.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 23:40:42.382467', '2026-02-16 23:40:42.382467');
INSERT INTO public.notification_rule VALUES ('e7d392f9-34d0-4f44-80d9-b3a0f2c85251', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณใกล้ครบกำหนด', 'หมวด Bills เหลืองบประมาณ 460.00 บาท (ใช้ไปแล้ว 90.80% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-16 23:41:18.687247', '2026-02-16 23:41:18.687247');
INSERT INTO public.notification_rule VALUES ('764465ea-a41e-4755-bea3-69b38862a8de', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'c19b655f-fda6-497c-9d9f-3c0a1c7ccf51', 'เตือนหนี้ครบกำหนด', 'หนี้ dkdkdj จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-17 04:18:44.915004', '2026-02-17 04:18:44.915049');
INSERT INTO public.notification_rule VALUES ('4d8f700d-e8ab-4209-9672-dc5e1957f9da', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '6245b010-e440-4c5e-a30b-9abd44a93064', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้กยศ. จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-17 06:29:39.703073', '2026-02-17 06:29:39.703084');
INSERT INTO public.notification_rule VALUES ('fefc4d4b-79e1-4f0d-bd5b-161665e8f57d', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '8a5e778f-4f7f-47a1-afe7-84a2da49780e', 'เตือนหนี้ครบกำหนด', 'หนี้ วดวดดว จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-17 06:31:26.052857', '2026-02-17 06:31:26.052867');
INSERT INTO public.notification_rule VALUES ('7f75247a-01eb-472e-97f6-2cf49efc1b5c', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '762def9e-82af-44cf-8c01-15faaa673cd6', 'เตือนหนี้ครบกำหนด', 'หนี้ วพวำว จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-17 06:34:25.381333', '2026-02-17 06:34:25.381342');
INSERT INTO public.notification_rule VALUES ('803fdb72-e768-4cab-a7c2-5cfeac449469', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '75a7cc2c-38fe-47d0-9758-57e9fce95314', 'เตือนหนี้ครบกำหนด', 'หนี้ test จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-17 06:54:30.698025', '2026-02-17 06:54:30.698034');
INSERT INTO public.notification_rule VALUES ('1792f469-0756-4303-b6a0-48bc7bdeee70', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '5bc6b981-bf44-4edc-a916-bbc76f419e75', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้กยศ. จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-02-17 07:29:16.398175', '2026-02-17 07:29:16.398188');
INSERT INTO public.notification_rule VALUES ('fb284045-4c05-4307-90a2-69f80ed3dd4a', 'f69c0230-b36a-4029-b128-d005743a0efb', 'BUDGET', NULL, 'เตือนงบประมาณใกล้ครบกำหนด', 'งบประมาณของ Health คงเหลือ 10.0 บาท (99.00% ของงบประมาณทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-02-17 07:40:57.147465', '2026-02-17 07:40:57.147478');
INSERT INTO public.notification_rule VALUES ('0dc6cf05-0bec-41fb-8b29-5e5a67f07dc2', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', 'eecb08e6-ab23-49fa-9e3b-e50892d4757c', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต KBank จำนวนขั้นต่ำ 2500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-10 10:23:02.945703', '2026-03-10 10:23:02.945703');
INSERT INTO public.notification_rule VALUES ('ff7751b1-d6ea-4a93-98b8-c9ff5a17ed52', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', '2bc4b142-830f-4bac-830a-4e02665a9a4f', 'เตือนหนี้ครบกำหนด', 'หนี้ สินเชื่อ CIMB จำนวนขั้นต่ำ 4500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-10 10:23:15.755609', '2026-03-10 10:23:15.755609');
INSERT INTO public.notification_rule VALUES ('d19c564a-a5cd-4d91-9fba-087200b0802b', 'f69c0230-b36a-4029-b128-d005743a0efb', 'DEBT', 'cc31fc89-a1f6-4cd8-9c7e-d1eceff84741', 'เตือนหนี้ครบกำหนด', 'หนี้ เงินกู้เฮียเมฆ จำนวนขั้นต่ำ 1000.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-10 10:23:27.257722', '2026-03-10 10:23:27.257722');
INSERT INTO public.notification_rule VALUES ('4e534b4e-a112-46e3-a1c5-0a7a9cda8850', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '6af095d3-9c19-4c52-994f-ff4e3ec9837b', 'เตือนหนี้ครบกำหนด', 'หนี้ dasdsa จำนวนขั้นต่ำ 111.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-10 15:06:47.758149', '2026-03-10 15:06:47.758159');
INSERT INTO public.notification_rule VALUES ('ccf483b6-72df-43bb-b88b-d94b4a3af645', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'DEBT', '7c67a0e2-8cf5-49b0-8ee6-d10b764a37bf', 'เตือนหนี้ครบกำหนด', 'หนี้ jyu จำนวนขั้นต่ำ 66.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-21 08:48:19.223274', '2026-03-21 08:48:19.223282');
INSERT INTO public.notification_rule VALUES ('65ec6c0b-3b02-4782-994d-8de62ccbcfff', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'DEBT', '8aed2a3c-ce19-4df4-9baf-f4b7ab3e0106', 'เตือนหนี้ครบกำหนด', 'หนี้ 444 จำนวนขั้นต่ำ 4.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-26 11:21:44.497766', '2026-03-26 11:21:44.497776');
INSERT INTO public.notification_rule VALUES ('b5dc3062-ec9e-49e3-8592-2af63410011e', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '57e83921-9103-4cbe-b496-8ef108dfd9cf', 'เตือนหนี้ครบกำหนด', 'หนี้ tesar1 จำนวนขั้นต่ำ 12121.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-26 18:33:01.013917', '2026-03-26 18:33:01.014321');
INSERT INTO public.notification_rule VALUES ('5e9ab107-1f19-4887-88d4-c94ba77ae168', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'b2d3082d-613d-4f90-a9c7-60a6c89dac32', 'เตือนหนี้ครบกำหนด', 'หนี้ 2323 จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-26 18:33:25.444248', '2026-03-26 18:33:25.444248');
INSERT INTO public.notification_rule VALUES ('f0f84d11-170d-4d52-a4f2-19e38f599fcd', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'e673177a-7b34-47d8-a392-2c4a424be5b0', 'เตือนหนี้ครบกำหนด', 'หนี้ test 1 จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-26 18:40:30.115568', '2026-03-26 18:40:30.115568');
INSERT INTO public.notification_rule VALUES ('4cd66ade-a637-4329-b33d-0dcda3c7f4c3', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 19000.00 บาท (ใช้ไป 2000.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-26 20:27:58.791835', '2026-03-26 20:27:58.791835');
INSERT INTO public.notification_rule VALUES ('7684f75a-4ac6-4a25-91b9-e84e7f216b31', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 0.00 บาท (ใช้ไป 100.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-26 21:06:58.02211', '2026-03-26 21:06:58.02211');
INSERT INTO public.notification_rule VALUES ('58a7a16a-523d-43fe-ad21-197f6c666a94', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 150.00 บาท (ใช้ไป 103.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-27 01:03:13.946892', '2026-03-27 01:03:13.947524');
INSERT INTO public.notification_rule VALUES ('5a0e4e65-f77b-478a-b681-45e470ea325f', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '93468174-040c-4e17-83da-cf9826ee74b2', 'เตือนหนี้ครบกำหนด', 'หนี้ coach nuu จำนวนขั้นต่ำ 50000.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-27 11:24:55.784033', '2026-03-27 11:24:55.784033');
INSERT INTO public.notification_rule VALUES ('b08dc031-3cb7-485f-b8fa-969a9cb52232', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 300.00 บาท (ใช้ไป 106.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-27 15:17:16.616598', '2026-03-27 15:17:16.616598');
INSERT INTO public.notification_rule VALUES ('810ebd0b-26bc-41a3-bc78-cd1306afb775', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 19035.00 บาท (ใช้ไป 2003.50% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-27 17:06:54.475303', '2026-03-27 17:06:54.475303');
INSERT INTO public.notification_rule VALUES ('244ca635-12ad-4017-a26a-e3d1b518b463', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 19105.00 บาท (ใช้ไป 2010.50% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-27 17:34:24.749758', '2026-03-27 17:34:24.750263');
INSERT INTO public.notification_rule VALUES ('6330a8bb-1b27-4f8e-a942-ca011c45f671', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'f05c4d56-6af0-431d-8707-d0aaccb59c89', 'เตือนหนี้ครบกำหนด', 'หนี้ KMUTT จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-28 15:05:36.806715', '2026-03-28 15:05:36.806715');
INSERT INTO public.notification_rule VALUES ('49df7936-d828-42bf-a2d5-f3792cc9d02a', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'ddc87222-50d6-4838-a452-81925f4a6f65', 'เตือนหนี้ครบกำหนด', 'หนี้ GTR จำนวนขั้นต่ำ 25000.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-28 19:08:49.731357', '2026-03-28 19:08:49.731875');
INSERT INTO public.notification_rule VALUES ('1ac012cc-bb5b-4e8a-a52c-abea5cc77783', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '4af70aae-d496-42ef-a1b3-2d166070ac88', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้บัตรเครดิต K-Bank (จ่ายขั้นต่ำ) จำนวนขั้นต่ำ 1500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-28 23:22:51.171293', '2026-03-28 23:22:51.171293');
INSERT INTO public.notification_rule VALUES ('b71fb343-3be7-40f2-8a55-366a7658ea60', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '7af75292-a3fd-4392-b7ec-8840c05ab8c2', 'เตือนหนี้ครบกำหนด', 'หนี้ เงินกู้ส่วนบุคคล (ผ่อนเท่ากันทุกเดือน) จำนวนขั้นต่ำ 4500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-28 23:23:02.077303', '2026-03-28 23:23:02.077303');
INSERT INTO public.notification_rule VALUES ('b4e8ce39-0996-401e-88a3-5131aa06aafd', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'e8c067a1-7c43-492a-b702-bedb56d47800', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้นอกระบบ (ดอกเบี้ยรายวัน) จำนวนขั้นต่ำ 150.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-28 23:23:12.111621', '2026-03-28 23:23:12.111621');
INSERT INTO public.notification_rule VALUES ('c0fe9c9e-8d29-4dd0-b913-90ece1de505b', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '48740e18-dcc2-46da-ab41-ee5b5c2af313', 'เตือนหนี้ครบกำหนด', 'หนี้ สินเชื่อรถยนต์ (ค้างชำระ - มีค่าปรับ) จำนวนขั้นต่ำ 8000.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-28 23:23:22.862572', '2026-03-28 23:23:22.862572');
INSERT INTO public.notification_rule VALUES ('a161f980-e4f4-4de9-b71e-1da43b178707', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '825f26af-b06a-4fe6-bbb5-7f1b36324885', 'เตือนหนี้ครบกำหนด', 'หนี้ ยืมเงินเพื่อน (จ่ายคืนก้อนเดียว) จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-28 23:23:33.780466', '2026-03-28 23:23:33.780466');
INSERT INTO public.notification_rule VALUES ('fd493683-d24d-44c3-ab3f-e0fde93cb9de', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '20147bdf-5186-45b6-a6c4-76d25a837e36', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต K-Bank (Platinum) จำนวนขั้นต่ำ 2500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 00:50:16.404196', '2026-03-29 00:50:16.404196');
INSERT INTO public.notification_rule VALUES ('30ce319b-1efc-4293-b844-3eba356ce728', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '8773ff37-7c33-425a-8170-2f34a78e3240', 'เตือนหนี้ครบกำหนด', 'หนี้ เงินกู้ส่วนบุคคล (Installment) จำนวนขั้นต่ำ 4500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 00:50:32.746102', '2026-03-29 00:50:32.746102');
INSERT INTO public.notification_rule VALUES ('122b118a-612f-4082-8ee6-43380367dcef', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '562187d0-e220-493d-be94-cf69aa5da993', 'เตือนหนี้ครบกำหนด', 'หนี้ เงินกู้ส่วนบุคคล (Installment) จำนวนขั้นต่ำ 4500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 01:00:07.03628', '2026-03-29 01:00:07.037311');
INSERT INTO public.notification_rule VALUES ('ae7c6aba-5b6f-4d82-b20f-0820e0a849ad', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '5530a784-3515-478d-beb7-9553179ad12d', 'เตือนหนี้ครบกำหนด', 'หนี้ เงินกู้ส่วนบุคคล (Installment) จำนวนขั้นต่ำ 4500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 01:16:53.808692', '2026-03-29 01:16:53.808692');
INSERT INTO public.notification_rule VALUES ('9a44c7ac-fabc-4f50-843d-e13fc7df927d', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '78341c6d-72ab-4e6d-91fa-657885c64df5', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต K-Bank (Platinum) จำนวนขั้นต่ำ 2500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 01:17:20.004424', '2026-03-29 01:17:20.004424');
INSERT INTO public.notification_rule VALUES ('469efa53-ae8c-4a26-820d-de54d258477b', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'ce90db18-2c43-4d7b-9902-77b718c2081a', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต K-Bank (Platinum) จำนวนขั้นต่ำ 2500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 01:33:32.870266', '2026-03-29 01:33:32.870266');
INSERT INTO public.notification_rule VALUES ('8a6bbc9a-b654-44ae-885f-7d53ef7e1f69', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'd5d1a1a9-a339-405a-83c5-89aaf4cd9544', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต K-Bank (Platinum) จำนวนขั้นต่ำ 2500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 03:43:14.369058', '2026-03-29 03:43:14.374282');
INSERT INTO public.notification_rule VALUES ('cf060a03-3502-4a67-9c5f-e7f24aa3e4af', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'd8c3474f-da06-4d68-ba4b-2dd884203075', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต K-Bank (Platinum) จำนวนขั้นต่ำ 2500.00 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 04:13:15.948641', '2026-03-29 04:13:15.948641');
INSERT INTO public.notification_rule VALUES ('e4797e02-2af4-4a4a-bc96-7f65bb86842c', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '7fb2b094-6d5d-473b-880d-2c9fa17baf00', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต K-Bank (Platinum) จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 04:20:32.73507', '2026-03-29 04:20:32.73507');
INSERT INTO public.notification_rule VALUES ('e93b9b96-bc59-4e73-b2e8-5f2a3748df86', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'fc81d7f6-2120-4524-b575-f82c2f6bc80e', 'เตือนหนี้ครบกำหนด', 'หนี้ สินเชื่อบุคคล UOB i-Cash จำนวนขั้นต่ำ 4500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 04:20:41.842503', '2026-03-29 04:20:41.842503');
INSERT INTO public.notification_rule VALUES ('f16b2838-989e-4102-91c0-376d02d6ff3b', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '359c74d3-1071-4b95-95f7-b7d655bdf4a5', 'เตือนหนี้ครบกำหนด', 'หนี้ กู้เงินนอกระบบ (เฮียเจี้ยง) จำนวนขั้นต่ำ 1000.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 04:20:50.479384', '2026-03-29 04:20:50.479384');
INSERT INTO public.notification_rule VALUES ('85853663-2746-4c4d-b037-8959c226f019', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'd5cc78be-c093-4af6-92de-87da63acccce', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้จัดชั้น (ค้างค่างวด) จำนวนขั้นต่ำ 8500.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 04:20:59.595095', '2026-03-29 04:20:59.595095');
INSERT INTO public.notification_rule VALUES ('7d057e9b-63c2-4c61-8ece-4c282a63e316', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 2232.00 บาท (ใช้ไป 323.20% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-29 05:19:09.02262', '2026-03-29 05:19:09.02262');
INSERT INTO public.notification_rule VALUES ('69162486-d0f4-4dbb-a397-e4cfe7c82d00', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 111.00 บาท (ใช้ไป 111.10% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-29 05:38:06.07912', '2026-03-29 05:38:06.07912');
INSERT INTO public.notification_rule VALUES ('c074ba84-81a7-418d-849b-4be14a1228a7', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1222.00 บาท (ใช้ไป 222.20% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-29 05:39:51.462693', '2026-03-29 05:39:51.462693');
INSERT INTO public.notification_rule VALUES ('0e4acd0e-1b5b-46f4-b5bb-08b5319ca88f', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 4000.00 บาท (ใช้ไป 500.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-29 20:26:50.442643', '2026-03-29 20:26:50.442643');
INSERT INTO public.notification_rule VALUES ('d8227f94-63ab-49b6-a3ae-8beb488ac7c3', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Bills ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-29 20:27:35.394124', '2026-03-29 20:27:35.394124');
INSERT INTO public.notification_rule VALUES ('b2471a53-b9cb-4a24-973d-9d38428f0482', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 9000.00 บาท (ใช้ไป 1000.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-30 00:14:42.402666', '2026-03-30 00:14:42.402666');
INSERT INTO public.notification_rule VALUES ('3fd46a1e-8ca7-4961-95e1-a9d656fb472e', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'f6d9a13d-f60d-47e3-aa99-2e6bf5d6ace1', 'เตือนหนี้ครบกำหนด', 'หนี้ test จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 17:43:39.099245', '2026-03-29 17:43:39.099258');
INSERT INTO public.notification_rule VALUES ('ddbe7397-77f4-4605-8d02-80b0a8c7c5dc', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Transport ใช้งบเกินแล้ว 500.00 บาท (ใช้ไป 150.00% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-30 00:49:12.535786', '2026-03-30 00:49:12.535786');
INSERT INTO public.notification_rule VALUES ('73c958b6-b2c4-44f0-8bd4-cdce84cbab2e', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'DEBT', '441fc156-b7f7-4b02-9a8d-1ed37ada9835', 'เตือนหนี้ครบกำหนด', 'หนี้ ddss จำนวนขั้นต่ำ 444.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-29 18:36:32.321268', '2026-03-29 18:36:32.321278');
INSERT INTO public.notification_rule VALUES ('404374a0-2b9b-492e-962d-2c8edb78027a', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Saving ใช้งบเกินแล้ว 1192.00 บาท (ใช้ไป 219.20% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-29 19:02:50.243221', '2026-03-29 19:02:50.243239');
INSERT INTO public.notification_rule VALUES ('39e6367f-93f4-4b3b-9d8b-1f8052acb3d1', '9db8aa73-7870-4481-a109-6430ca921dd5', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 1323.00 บาท (ใช้ไป 232.30% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-29 21:29:53.543874', '2026-03-29 21:29:53.543879');
INSERT INTO public.notification_rule VALUES ('998b0938-3ffe-4491-b531-905f671ce8ee', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'DEBT', 'c7157984-89d3-48ae-a619-84a4890f7a60', 'เตือนหนี้ครบกำหนด', 'หนี้ rrrr จำนวนขั้นต่ำ 4.0 บาทครบกำหนดวันนี้', 3, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 05:20:40.576847', '2026-03-30 05:20:40.576849');
INSERT INTO public.notification_rule VALUES ('f038ed75-4448-4eaf-a883-561363b5da13', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Food ใช้งบเกินแล้ว 10080.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-30 05:48:36.584638', '2026-03-30 05:48:36.584641');
INSERT INTO public.notification_rule VALUES ('7073c983-8f4c-424a-88eb-ee74e1fde098', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '776dd379-98e1-478c-8ff6-15732f9464fe', 'เตือนหนี้ครบกำหนด', 'หนี้ debt 1 จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 05:50:25.638098', '2026-03-30 05:50:25.638101');
INSERT INTO public.notification_rule VALUES ('d2ab945c-491d-4531-84fd-8a1f73f56184', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 5055.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-03-30 05:51:14.452355', '2026-03-30 05:51:14.452366');
INSERT INTO public.notification_rule VALUES ('0a11c52b-5ecc-41e3-92fc-a54c93f8166b', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'ac045b98-67ea-4e0e-b8be-7f127e12f1c5', 'เตือนหนี้ครบกำหนด', 'หนี้ debt 2 จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 05:57:42.491527', '2026-03-30 05:57:42.491531');
INSERT INTO public.notification_rule VALUES ('a82319f6-bf36-4940-b01c-74c5b778a327', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'b23f2f2c-8691-4c79-9aff-50d9e8c43cb5', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้4 จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 06:19:59.317025', '2026-03-30 06:19:59.317027');
INSERT INTO public.notification_rule VALUES ('c1f77c9a-206c-4f00-b157-eaf273998c84', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '3906dae9-b751-43a3-b605-e269188ff179', 'เตือนหนี้ครบกำหนด', 'หนี้ debt1 จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 06:42:15.121423', '2026-03-30 06:42:15.121441');
INSERT INTO public.notification_rule VALUES ('f967264b-fb4c-4e6c-8668-70868f9af73c', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '0368036a-8289-406e-b9cf-12ba7d92dd83', 'เตือนหนี้ครบกำหนด', 'หนี้ debt2 จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 06:42:42.981106', '2026-03-30 06:42:42.981118');
INSERT INTO public.notification_rule VALUES ('2a81de1b-81e9-4fdc-bad3-5e025a8eebca', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'dd2589f3-a0aa-415a-b1f1-374761c566bb', 'เตือนหนี้ครบกำหนด', 'หนี้ test จำนวนขั้นต่ำ 1000.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 06:51:14.973711', '2026-03-30 06:51:14.973721');
INSERT INTO public.notification_rule VALUES ('dc197028-d6c3-427c-adab-6f93cd8e2845', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'e51fc3ee-6dbb-483e-a0dc-c0aeec0ad5cb', 'เตือนหนี้ครบกำหนด', 'หนี้ debt2 จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 07:33:01.421226', '2026-03-30 07:33:01.421238');
INSERT INTO public.notification_rule VALUES ('41c09d12-3bfd-47dc-aaa0-644bbe067906', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '3004d5cd-1cd0-45b3-8c61-21ff84f70fb8', 'เตือนหนี้ครบกำหนด', 'หนี้ debt3 จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 07:57:35.170599', '2026-03-30 07:57:35.170607');
INSERT INTO public.notification_rule VALUES ('38b4f56a-ccff-46b7-a78a-f52cac67e6e0', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'a98cd06a-ba3c-4856-bfcb-0c8fca5b6e3a', 'เตือนหนี้ครบกำหนด', 'หนี้ กยศ จำนวนขั้นต่ำ 500.0 บาทครบกำหนดวันนี้', 4, '09:00:00', 'Asia/Bangkok', true, '2026-03-30 10:17:45.879968', '2026-03-30 10:17:45.879977');
INSERT INTO public.notification_rule VALUES ('070bdbdf-dc78-4470-9ed1-ed282f8ee2e3', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', 'c3c9a4e0-933c-4fa7-accf-2bfe788128eb', 'เตือนหนี้ครบกำหนด', 'หนี้ etetete จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 2, '00:00:00', 'Asia/Bangkok', true, '2026-04-07 13:07:46.006926', '2026-04-07 13:07:46.007933');
INSERT INTO public.notification_rule VALUES ('baf9b073-a2f5-4cd6-8fe6-2bbb9c35f190', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '1b367913-2fa1-487c-81da-63f5c47ad86d', 'เตือนหนี้ครบกำหนด', 'หนี้ test จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 2, '00:00:00', 'Asia/Bangkok', true, '2026-04-07 13:08:26.800006', '2026-04-07 13:08:26.800006');
INSERT INTO public.notification_rule VALUES ('0d8b05a0-636a-4334-b2a1-8cf195ef774f', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '5c6bf689-bbfb-4b71-9a34-c720fb25fd53', 'เตือนหนี้ครบกำหนด', 'หนี้ บ้านหลังแรกกกก จำนวนขั้นต่ำ 18500.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-07 07:16:48.922375', '2026-04-07 07:16:48.9224');
INSERT INTO public.notification_rule VALUES ('66a02ab2-c5e9-4188-90ee-01b0ecec3bfe', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '18fd7cb9-d0e7-4e65-bcde-10149589bd5f', 'เตือนหนี้ครบกำหนด', 'หนี้ สินเชื่อเช่ารถ จำนวนขั้นต่ำ 14200.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-07 07:18:59.687489', '2026-04-07 07:18:59.687504');
INSERT INTO public.notification_rule VALUES ('fd414f70-f7c4-4593-9fb3-0c559b48f211', '9db8aa73-7870-4481-a109-6430ca921dd5', 'DEBT', '1a7c7973-1bc3-4661-91b2-b90e31755fb2', 'เตือนหนี้ครบกำหนด', 'หนี้ บัตรเครดิต KBank Shopee จำนวนขั้นต่ำ 2500.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-07 07:21:37.03002', '2026-04-07 07:21:37.030035');
INSERT INTO public.notification_rule VALUES ('6b35b455-8a3c-4095-9e7f-292d71b79821', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '6abe3dbd-12d9-4372-887c-03d381fd296d', 'เตือนหนี้ครบกำหนด', 'หนี้ ttb จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-07 08:01:06.249783', '2026-04-07 08:01:06.249793');
INSERT INTO public.notification_rule VALUES ('3e670710-a53f-449b-a98c-44fd4b4d3bfa', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'e0222a57-4294-48ce-9bd1-ae4f3668db23', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้บ้าน จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-20 15:08:38.762767', '2026-04-20 15:08:38.762787');
INSERT INTO public.notification_rule VALUES ('8f608492-b773-45bc-a9eb-28d6a1d076e4', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'ff3f99d9-66cd-45d5-a1f9-9cda099837c0', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้ก้า จำนวนขั้นต่ำ 1.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 02:01:20.988908', '2026-04-27 02:01:20.988921');
INSERT INTO public.notification_rule VALUES ('183d2c94-2fc8-40ab-ba72-211881a2f38b', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '653d37ab-d095-4cf6-aae1-31f68e5e479e', 'เตือนหนี้ครบกำหนด', 'หนี้ game จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 02:49:33.021252', '2026-04-27 02:49:33.021265');
INSERT INTO public.notification_rule VALUES ('401bb88b-479a-426e-9491-18bc0ada9081', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '64f0315a-6727-4f2d-826d-aae948d888c0', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้รถ จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 02:59:20.976058', '2026-04-27 02:59:20.976066');
INSERT INTO public.notification_rule VALUES ('161d3cf7-291e-4b64-83e7-c59185dd4ec7', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'd9cffec7-8a6d-47f6-8bad-46b819888e28', 'เตือนหนี้ครบกำหนด', 'หนี้ หนี้รถ จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 03:13:28.208941', '2026-04-27 03:13:28.208954');
INSERT INTO public.notification_rule VALUES ('93b728d2-d8c1-4c8d-95e7-cda94014e664', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'e17a1f69-74e6-48c9-98e5-e47c6a2d3f17', 'เตือนหนี้ครบกำหนด', 'หนี้ byd จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 03:57:53.094964', '2026-04-27 03:57:53.09498');
INSERT INTO public.notification_rule VALUES ('5136e6e0-f3ef-4c66-862e-eddf64350642', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', 'f3efc943-84d9-4174-a0d0-5c138bfe3cd3', 'เตือนหนี้ครบกำหนด', 'หนี้ wave จำนวนขั้นต่ำ 0.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 04:41:50.723963', '2026-04-27 04:41:50.723981');
INSERT INTO public.notification_rule VALUES ('ae2e449e-c142-475a-86c5-46e4c66963f9', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '22bf0719-3387-4259-aee9-2ca7d8a1d072', 'เตือนหนี้ครบกำหนด', 'หนี้ scb จำนวนขั้นต่ำ 5000.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 05:18:35.867752', '2026-04-27 05:18:35.867761');
INSERT INTO public.notification_rule VALUES ('f0bdf97f-83b9-4063-a3e5-613c22393fb2', '0f43a469-1931-4108-8d76-81f5b8604168', 'DEBT', '4d77a1ab-32d2-4aba-ae97-36acab6cc263', 'เตือนหนี้ครบกำหนด', 'หนี้ กระนูย จำนวนขั้นต่ำ 1000.0 บาทครบกำหนดวันนี้', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 05:57:14.547116', '2026-04-27 05:57:14.547129');
INSERT INTO public.notification_rule VALUES ('4e3725b0-60c0-414c-8225-f76f7c614076', '0f43a469-1931-4108-8d76-81f5b8604168', 'BUDGET', NULL, 'แจ้งเตือนงบประมาณเกินกำหนด', 'หมวด Salary ใช้งบเกินแล้ว 20.00 บาท (ใช้ไป Infinity% ของงบทั้งหมด)', 0, NULL, 'Asia/Bangkok', true, '2026-04-27 06:13:44.68997', '2026-04-27 06:13:44.689979');


--
-- TOC entry 3598 (class 0 OID 16924)
-- Dependencies: 227
-- Data for Name: receiver_mappings; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.receiver_mappings VALUES (1, '2026-03-27 01:03:36.295513', 'youtube music', '0f43a469-1931-4108-8d76-81f5b8604168', 292, NULL);
INSERT INTO public.receiver_mappings VALUES (2, '2026-03-27 01:43:47.886433', 'taxi', '0f43a469-1931-4108-8d76-81f5b8604168', 289, NULL);
INSERT INTO public.receiver_mappings VALUES (6, '2026-03-29 05:39:52.010518', '212', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 308, NULL);
INSERT INTO public.receiver_mappings VALUES (7, '2026-03-29 13:39:00.250552', 'test', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 308, NULL);
INSERT INTO public.receiver_mappings VALUES (8, '2026-03-29 13:53:42.231275', 'aaaa', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 312, NULL);
INSERT INTO public.receiver_mappings VALUES (9, '2026-03-29 18:38:40.670483', 'ทรู มันนี่ วอลเล็ท 0084071040', '0f43a469-1931-4108-8d76-81f5b8604168', 293, NULL);
INSERT INTO public.receiver_mappings VALUES (12, '2026-03-30 00:40:01.568315', 'สแกนตรวจสอบ', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 316, NULL);
INSERT INTO public.receiver_mappings VALUES (26, '2026-04-07 11:27:53.491699', 'นาย ภูริ', '9db8aa73-7870-4481-a109-6430ca921dd5', 299, NULL);
INSERT INTO public.receiver_mappings VALUES (27, '2026-04-07 07:25:02.357858', 'อเมซอน', '9db8aa73-7870-4481-a109-6430ca921dd5', 298, NULL);
INSERT INTO public.receiver_mappings VALUES (28, '2026-04-07 07:28:04.528735', 'ปตท', '9db8aa73-7870-4481-a109-6430ca921dd5', 299, NULL);
INSERT INTO public.receiver_mappings VALUES (29, '2026-04-07 07:29:18.27517', '7-11', '9db8aa73-7870-4481-a109-6430ca921dd5', 301, NULL);
INSERT INTO public.receiver_mappings VALUES (30, '2026-04-07 14:35:01.025489', 'ร้านข้าวป้าแดง', '9db8aa73-7870-4481-a109-6430ca921dd5', 298, NULL);
INSERT INTO public.receiver_mappings VALUES (32, '2026-04-27 14:15:57.455476', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', '0f43a469-1931-4108-8d76-81f5b8604168', 288, NULL);
INSERT INTO public.receiver_mappings VALUES (33, '2026-06-17 14:19:36.906651', 'นาง สุจินดา ชัยฤทธิ์ พร้อมเพย์', '0f43a469-1931-4108-8d76-81f5b8604168', 288, NULL);
INSERT INTO public.receiver_mappings VALUES (34, '2026-06-17 14:19:46.643444', 'แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย', '0f43a469-1931-4108-8d76-81f5b8604168', 289, NULL);


--
-- TOC entry 3601 (class 0 OID 16929)
-- Dependencies: 230
-- Data for Name: repayment_plan; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.repayment_plan VALUES ('3de50ecd-1a4c-4498-9027-0e991577f587', 'f69c0230-b36a-4029-b128-d005743a0efb', 8000.00, '2026-02-16 14:18:25.848635', '2465434e-b956-4fd5-a1a3-6f04e36ab1ef', NULL);
INSERT INTO public.repayment_plan VALUES ('c0d3e1f9-4071-4db2-9323-648e68250214', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 0.00, '2026-03-19 08:08:28.562098', 'a36d0216-14bb-4e82-8f99-677f58c53f9a', NULL);
INSERT INTO public.repayment_plan VALUES ('2883576e-813e-444d-a24f-6f99fb84cf66', '9db8aa73-7870-4481-a109-6430ca921dd5', 58003.00, '2026-02-16 07:12:13.918615', 'a36d0216-14bb-4e82-8f99-677f58c53f9a', NULL);
INSERT INTO public.repayment_plan VALUES ('4bfe204f-02a8-41c1-a142-84bebd543af4', '0f43a469-1931-4108-8d76-81f5b8604168', 7245.00, '2026-03-27 11:25:29.001102', 'a36d0216-14bb-4e82-8f99-677f58c53f9a', NULL);


--
-- TOC entry 3602 (class 0 OID 16932)
-- Dependencies: 231
-- Data for Name: repayment_plan_result; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3603 (class 0 OID 16935)
-- Dependencies: 232
-- Data for Name: repayment_strategy; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.repayment_strategy VALUES ('a36d0216-14bb-4e82-8f99-677f58c53f9a', 'OPTIMAL_COST', 'กลยุทธ์การชำระหนี้โดยเริ่มจากหนี้ที่มียอดคงเหลือน้อยที่สุดก่อน เพื่อให้สามารถปิดหนี้ได้เร็ว สร้างแรงจูงใจและวินัยในการชำระหนี้อย่างต่อเนื่อง', true, '2026-03-10 10:25:15.007238', '{Interest,Penalty,Informal,Cost-Saving}');
INSERT INTO public.repayment_strategy VALUES ('2465434e-b956-4fd5-a1a3-6f04e36ab1ef', 'SNOWBALL', 'กลยุทธ์การชำระหนี้โดยเริ่มจากหนี้ที่มียอดคงเหลือน้อยที่สุดก่อน เพื่อให้สามารถปิดหนี้ได้เร็ว สร้างแรงจูงใจและวินัยในการชำระหนี้อย่างต่อเนื่อง', true, '2026-01-27 10:49:52.791621', '{"Quick wins","High motivation","Beginner friendly","Simple to follow"}');
INSERT INTO public.repayment_strategy VALUES ('bdeb0391-ae42-4e49-8fba-ed41efda8c4c', 'AVALANCHE', 'กลยุทธ์การชำระหนี้โดยให้ความสำคัญกับหนี้ที่มีอัตราดอกเบี้ยสูงที่สุดก่อน เพื่อลดภาระดอกเบี้ยรวมและระยะเวลาการเป็นหนี้ในระยะยาว', true, '2026-01-27 11:08:52.45158', '{"Saves most money","Reduces interest","Math optimal"}');
INSERT INTO public.repayment_strategy VALUES ('fde4dc08-3eb7-4144-a4b9-05a5e7524ea9', 'MINIMUM_ONLY', 'กลยุทธ์การชำระหนี้โดยชำระเฉพาะยอดขั้นต่ำของแต่ละหนี้ เหมาะสำหรับกรณีฉุกเฉินที่ผู้ใช้งานมีข้อจำกัดด้านสภาพคล่องทางการเงิน', true, '2026-01-27 11:09:19.993421', '{"Lowest payment","Cashflow control",Flexible}');


--
-- TOC entry 3604 (class 0 OID 16940)
-- Dependencies: 233
-- Data for Name: repayment_type; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.repayment_type VALUES (5, 'Full Payment / Lump Sum', 'จ่ายครั้งเดียวเมื่อถึงกำหนด ครอบคลุมทั้งเงินต้นและดอกเบี้ย');
INSERT INTO public.repayment_type VALUES (6, 'Installment / EMI', 'จ่ายแบบผ่อนเป็นงวด ๆ รวมทั้งเงินต้นและดอกเบี้ยในแต่ละงวด');
INSERT INTO public.repayment_type VALUES (7, 'Revolving / Credit Line', 'จ่ายขั้นต่ำบางส่วน ส่วนที่เหลือคงค้างและเกิดดอกเบี้ยต่อ');
INSERT INTO public.repayment_type VALUES (8, 'Bullet Payment', 'จ่ายเฉพาะดอกเบี้ยระหว่างงวด และจ่ายเงินต้นเต็มจำนวนเมื่อสิ้นสุดสัญญา');


--
-- TOC entry 3607 (class 0 OID 16947)
-- Dependencies: 236
-- Data for Name: slips; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.slips VALUES (1, 'f69c0230-b36a-4029-b128-d005743a0efb', 'KTB', 'Neanjung', 79.00, '2569-02-28 16:50:00', NULL, '2026/03/12/7242c455-b728-48b9-a74f-bafc1468038e.jpg', '0042000600000101030060221C202602286059160480575102TH9104E40C', '{"bank": "KTB", "date": "28 ก.พ. 2569 16:50", "memo": null, "valid": true, "amount": "79.00", "qr_raw": "0042000600000101030060221C202602286059160480575102TH9104E40C", "receiver": "Neanjung"}', 'processed', '2026-03-12 14:15:05.1348');
INSERT INTO public.slips VALUES (2, 'f69c0230-b36a-4029-b128-d005743a0efb', 'KTB', 'นาง ประนอม วงค์เสน', 70.00, '2569-02-20 19:46:00', NULL, '2026/03/12/e4115356-3c23-4dc7-9728-1fb140e6744f.jpg', '0038000600000101030060217Af8d0611ea7944d455102TH9104629F', '{"bank": "KTB", "date": "20 ก.พ. 2569 19:46", "memo": null, "valid": true, "amount": "70.00", "qr_raw": "0038000600000101030060217Af8d0611ea7944d455102TH9104629F", "receiver": "นาง ประนอม วงค์เสน"}', 'processed', '2026-03-12 14:15:05.259155');
INSERT INTO public.slips VALUES (3, 'f69c0230-b36a-4029-b128-d005743a0efb', 'KTB', 'ทรู มันนี่ วอลเล็ท 0840710405', 200.00, '2569-02-27 21:46:00', NULL, '2026/03/12/b268a5e6-82e5-4a4c-8c46-f1bee0cd9940.jpg', NULL, '{"bank": "KTB", "date": "27 ก.พ. 2569 21:46", "memo": null, "valid": true, "amount": "200.00", "receiver": "ทรู มันนี่ วอลเล็ท 0840710405"}', 'processed', '2026-03-12 14:15:05.269729');
INSERT INTO public.slips VALUES (4, 'f69c0230-b36a-4029-b128-d005743a0efb', 'KBANK', 'นาย  สรณัฐ แสงรุ่งเรือง', 600.00, '2569-02-21 11:17:00', NULL, '2026/03/12/54e7f945-ee09-4157-b1a3-4ac7c6c40142.jpg', '0038000600000101030060217Aae39ddf3881e4ab55102TH9104DC61', '{"bank": "KBANK", "date": "21 ก.พ. 2569 11:17", "memo": null, "valid": true, "amount": "600.00", "qr_raw": "0038000600000101030060217Aae39ddf3881e4ab55102TH9104DC61", "receiver": "นาย  สรณัฐ แสงรุ่งเรือง"}', 'processed', '2026-03-12 14:15:05.27873');
INSERT INTO public.slips VALUES (5, 'f69c0230-b36a-4029-b128-d005743a0efb', 'KTB', 'ถุงเงิน ร้านป้านกตามสั่ง', 70.00, '2569-02-28 12:07:00', NULL, '2026/03/12/9e2455e9-4b8c-415c-a352-4f827a235949.jpg', '0042000600000101030060221C202602286059124999865102TH9104CD45', '{"bank": "KTB", "date": "28 ก.พ. 2569 12:07", "memo": null, "valid": true, "amount": "70.00", "qr_raw": "0042000600000101030060221C202602286059124999865102TH9104CD45", "receiver": "ถุงเงิน ร้านป้านกตามสั่ง"}', 'processed', '2026-03-12 14:15:05.285733');
INSERT INTO public.slips VALUES (13, 'f69c0230-b36a-4029-b128-d005743a0efb', 'KTB', 'Neanjung', 79.00, '2569-02-28 16:50:00', NULL, '2026/03/27/58e84e47-0aeb-48d9-965c-57ad5871f670.jpg', '0042000600000101030060221C202602286059160480575102TH9104E40C', '{"bank": "KTB", "date": "28 ก.พ. 2569 16:50", "memo": null, "valid": true, "amount": "79.00", "qr_raw": "0042000600000101030060221C202602286059160480575102TH9104E40C", "receiver": "Neanjung"}', 'processed', '2026-03-27 16:40:19.446799');
INSERT INTO public.slips VALUES (28, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/880d6ee1-8e8b-4ce3-9d42-9596e5a3e2da.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 14:48:05.305035');
INSERT INTO public.slips VALUES (29, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/a6a04339-3c9b-4fd4-a8b0-fb746526c192.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 14:53:47.189685');
INSERT INTO public.slips VALUES (30, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/5a505001-6915-4d0d-a205-173a0ffc4b0f.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 15:06:35.46191');
INSERT INTO public.slips VALUES (31, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/77462297-1a10-4171-8b88-4313ed8aa942.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 15:14:04.198309');
INSERT INTO public.slips VALUES (34, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/74be83e7-09c0-45de-81cb-357026a14205.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 15:21:33.669812');
INSERT INTO public.slips VALUES (35, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BAY', 'สแกนตรวจสอบ', 5000.00, '2568-01-01 12:00:00', 'ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น', '2026/03/29/04312e03-3f4c-41c3-afeb-c40880af35bc.jpg', 'http://en.m.wikipedia.org', '{"bank": "BAY", "date": "01 ม.ค. 2568 12:00", "memo": "ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น", "valid": true, "amount": "5000.00", "qr_raw": "http://en.m.wikipedia.org", "receiver": "สแกนตรวจสอบ"}', 'processed', '2026-03-29 15:26:51.781199');
INSERT INTO public.slips VALUES (36, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/fdeb8ee5-4394-4b1d-bbe6-f91429868c49.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 15:30:14.514089');
INSERT INTO public.slips VALUES (37, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/a8b44930-40f2-44c3-9beb-c1d520ee9d89.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 15:33:09.283376');
INSERT INTO public.slips VALUES (39, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KTB', 'นาย ภูริ ไชยนิคม พร้อมเพย์  x', 80.00, '2569-03-12 21:06:00', NULL, '2026/03/29/6d561b0d-2dde-4134-a893-cd7afed2cf8a.jpg', '0038000600000101030060217A286cb1c2814941255102TH9104876C', '{"bank": "KTB", "date": "12 มี.ค. 2569 21:06", "memo": null, "valid": true, "amount": "80.00", "qr_raw": "0038000600000101030060217A286cb1c2814941255102TH9104876C", "receiver": "นาย ภูริ ไชยนิคม พร้อมเพย์  x"}', 'processed', '2026-03-29 15:43:47.032531');
INSERT INTO public.slips VALUES (40, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/610b93bb-2e65-491c-9d6a-1c7357999e24.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 15:47:49.347576');
INSERT INTO public.slips VALUES (44, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BAY', 'สแกนตรวจสอบ', 5000.00, '2568-01-01 12:00:00', 'ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น', '2026/03/29/48b88093-dfa4-47ff-a3cb-4ca199da943c.jpg', 'http://en.m.wikipedia.org', '{"bank": "BAY", "date": "01 ม.ค. 2568 12:00", "memo": "ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น", "valid": true, "amount": "5000.00", "qr_raw": "http://en.m.wikipedia.org", "receiver": "สแกนตรวจสอบ"}', 'processed', '2026-03-29 20:26:45.083246');
INSERT INTO public.slips VALUES (45, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/aff586a7-0d81-42fe-aedc-9bc3a16f8b50.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 20:27:26.008156');
INSERT INTO public.slips VALUES (46, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BBL', 'ทรู มันนี่ วอลเล็ท 0049990598', 2192.00, NULL, NULL, '2026/03/30/c4cf5d6e-b32b-4efd-b856-bead695949af.jpg', '004600060000010103002022520260312211050230020349085102TH9104980E', '{"bank": "BBL", "date": "12 มี.ค. 69, 21:10", "memo": null, "valid": true, "amount": "2192.00", "qr_raw": "004600060000010103002022520260312211050230020349085102TH9104980E", "receiver": "ทรู มันนี่ วอลเล็ท 0049990598"}', 'processed', '2026-03-30 00:03:52.598635');
INSERT INTO public.slips VALUES (47, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'TTB', 'calutor: utiitiยs ragroncu กาเาาณ^ด4กา.าาา', 10000.00, NULL, NULL, '2026/03/30/2bc24fff-8cbe-451a-b7c9-f50f489cf94f.jpg', NULL, '{"bank": "TTB", "date": null, "memo": null, "valid": true, "amount": "10000.00", "receiver": "calutor: utiitiยs ragroncu กาเาาณ^ด4กา.าาา"}', 'processed', '2026-03-30 00:04:09.390401');
INSERT INTO public.slips VALUES (49, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BBL', 'ทรู มันนี่ วอลเล็ท 0049990598', 2192.00, NULL, NULL, '2026/03/30/7e193558-935f-40f3-b529-24b850c244e4.jpg', '004600060000010103002022520260312211050230020349085102TH9104980E', '{"bank": "BBL", "date": "12 มี.ค. 69, 21:10", "memo": null, "valid": true, "amount": "2192.00", "qr_raw": "004600060000010103002022520260312211050230020349085102TH9104980E", "receiver": "ทรู มันนี่ วอลเล็ท 0049990598"}', 'processed', '2026-03-30 00:05:58.661275');
INSERT INTO public.slips VALUES (50, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KTB', 'นาย ภูริ ไชยนิคม พร้อมเพย์  x', 80.00, '2569-03-12 21:06:00', NULL, '2026/03/30/8f46bf64-430c-47c0-9141-b74a16152c6a.jpg', '0038000600000101030060217A286cb1c2814941255102TH9104876C', '{"bank": "KTB", "date": "12 มี.ค. 2569 21:06", "memo": null, "valid": true, "amount": "80.00", "qr_raw": "0038000600000101030060217A286cb1c2814941255102TH9104876C", "receiver": "นาย ภูริ ไชยนิคม พร้อมเพย์  x"}', 'processed', '2026-03-30 00:06:19.430634');
INSERT INTO public.slips VALUES (51, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'SCB', 'นาย ธนากร ขวัญพูล', 1000.00, '2565-11-02 11:34:00', 'ชาญ', '2026/03/30/42515248-9b39-4f6b-9e55-40a0c5ced925.jpg', '0046000600000101030140225202211022XMj8r6IIId6H8WNs5102TH91040F7E', '{"bank": "SCB", "date": "02 พ.ย. 2565 11:34", "memo": "ชาญ", "valid": true, "amount": "1000.00", "qr_raw": "0046000600000101030140225202211022XMj8r6IIId6H8WNs5102TH91040F7E", "receiver": "นาย ธนากร ขวัญพูล"}', 'processed', '2026-03-30 00:06:38.959028');
INSERT INTO public.slips VALUES (52, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'TTB', 'calutor: utiitiยs ragroncu กาเาาณ^ด4กา.าาา', 10000.00, NULL, NULL, '2026/03/30/5faadd5b-d4f3-4e20-88e4-8abb5a449d52.jpg', NULL, '{"bank": "TTB", "date": null, "memo": null, "valid": true, "amount": "10000.00", "receiver": "calutor: utiitiยs ragroncu กาเาาณ^ด4กา.าาา"}', 'processed', '2026-03-30 00:07:05.568522');
INSERT INTO public.slips VALUES (53, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 52.00, NULL, NULL, '2026/03/29/24a70c2b-d0c1-462f-9f57-2f028887a2d7.jpg', '0041000600000101030040220016088172323APP095475102TH9104BA2D', '{"bank": "KBANK", "date": "29 มี.ค. 69  17:23", "memo": null, "valid": true, "amount": "52.00", "qr_raw": "0041000600000101030040220016088172323APP095475102TH9104BA2D", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-03-29 17:07:50.749437');
INSERT INTO public.slips VALUES (54, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BAY', 'สแกนตรวจสอบ', 5000.00, '2568-01-01 12:00:00', 'ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น', '2026/03/30/fc93a707-fc5d-4f2e-b9da-f362a2e2680c.jpg', 'http://en.m.wikipedia.org', '{"bank": "BAY", "date": "01 ม.ค. 2568 12:00", "memo": "ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น", "valid": true, "amount": "5000.00", "qr_raw": "http://en.m.wikipedia.org", "receiver": "สแกนตรวจสอบ"}', 'processed', '2026-03-30 00:14:25.124537');
INSERT INTO public.slips VALUES (55, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/30/29503aa1-af9b-43ce-a785-acf0c4f4eef2.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-30 00:20:05.396803');
INSERT INTO public.slips VALUES (56, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BAY', 'สแกนตรวจสอบ', 5000.00, '2568-01-01 12:00:00', 'ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น', '2026/03/30/8640313e-6b8c-4534-b5fb-f694a27b3795.jpg', 'http://en.m.wikipedia.org', '{"bank": "BAY", "date": "01 ม.ค. 2568 12:00", "memo": "ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น", "valid": true, "amount": "5000.00", "qr_raw": "http://en.m.wikipedia.org", "receiver": "สแกนตรวจสอบ"}', 'processed', '2026-03-30 00:21:35.485925');
INSERT INTO public.slips VALUES (57, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 52.00, NULL, NULL, '2026/03/29/c7143e37-a000-4c0d-bedf-ee26bb842ef4.jpg', '0041000600000101030040220016088172323APP095475102TH9104BA2D', '{"bank": "KBANK", "date": "29 มี.ค. 69  17:23", "memo": null, "valid": true, "amount": "52.00", "qr_raw": "0041000600000101030040220016088172323APP095475102TH9104BA2D", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-03-29 17:21:42.472358');
INSERT INTO public.slips VALUES (58, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/30/916f1bcf-3a9d-4b02-823d-a509f31ba0f9.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-30 00:25:10.939026');
INSERT INTO public.slips VALUES (59, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/30/76260c02-73f2-4ac9-bfed-ed5d0a6d5966.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-30 00:49:04.676968');
INSERT INTO public.slips VALUES (60, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 52.00, NULL, NULL, '2026/03/29/28a3c91c-fe10-46e7-b74b-5e0f29302a53.jpg', '0041000600000101030040220016088172323APP095475102TH9104BA2D', '{"bank": "KBANK", "date": "29 มี.ค. 69  17:23", "memo": null, "valid": true, "amount": "52.00", "qr_raw": "0041000600000101030040220016088172323APP095475102TH9104BA2D", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-03-29 17:49:59.463892');
INSERT INTO public.slips VALUES (61, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 52.00, NULL, NULL, '2026/03/29/563d3ab7-167f-481b-b56f-14e5f02d4512.jpg', '0041000600000101030040220016088172323APP095475102TH9104BA2D', '{"bank": "KBANK", "date": "29 มี.ค. 69  17:23", "memo": null, "valid": true, "amount": "52.00", "qr_raw": "0041000600000101030040220016088172323APP095475102TH9104BA2D", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-03-29 17:50:13.866777');
INSERT INTO public.slips VALUES (62, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 52.00, NULL, NULL, '2026/03/29/ad839761-038c-44d0-ba10-891078794e9e.jpg', '0041000600000101030040220016088172323APP095475102TH9104BA2D', '{"bank": "KBANK", "date": "29 มี.ค. 69  17:23", "memo": null, "valid": true, "amount": "52.00", "qr_raw": "0041000600000101030040220016088172323APP095475102TH9104BA2D", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-03-29 17:50:40.532071');
INSERT INTO public.slips VALUES (63, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 52.00, NULL, NULL, '2026/03/29/2d2652f9-b608-4ee3-bd02-2fc0698f10c8.jpg', '0041000600000101030040220016088172323APP095475102TH9104BA2D', '{"bank": "KBANK", "date": "29 มี.ค. 69  17:23", "memo": null, "valid": true, "amount": "52.00", "qr_raw": "0041000600000101030040220016088172323APP095475102TH9104BA2D", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-03-29 17:54:22.334899');
INSERT INTO public.slips VALUES (64, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 52.00, NULL, NULL, '2026/03/29/ee38100a-49ee-4821-a3ee-9db956ce06b9.jpg', '0041000600000101030040220016088172323APP095475102TH9104BA2D', '{"bank": "KBANK", "date": "29 มี.ค. 69  17:23", "memo": null, "valid": true, "amount": "52.00", "qr_raw": "0041000600000101030040220016088172323APP095475102TH9104BA2D", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-03-29 17:54:54.207545');
INSERT INTO public.slips VALUES (65, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/5731558a-6b31-47ec-87dc-a339923c0c45.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 18:19:49.339202');
INSERT INTO public.slips VALUES (66, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/29/5882e1c4-4a70-4c16-bc96-8c66c63c8b61.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-29 18:34:52.450913');
INSERT INTO public.slips VALUES (67, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BBL', 'ทรู มันนี่ วอลเล็ท 0049990598', 2192.00, NULL, NULL, '2026/03/29/21cea4fa-b20d-479d-aa4c-046e524a8f0f.jpg', '004600060000010103002022520260312211050230020349085102TH9104980E', '{"bank": "BBL", "date": "12 มี.ค. 69, 21:10", "memo": null, "valid": true, "amount": "2192.00", "qr_raw": "004600060000010103002022520260312211050230020349085102TH9104980E", "receiver": "ทรู มันนี่ วอลเล็ท 0049990598"}', 'processed', '2026-03-29 19:02:11.7908');
INSERT INTO public.slips VALUES (68, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BBL', 'ทรู มันนี่ วอลเล็ท 0049990598', 2192.00, NULL, NULL, '2026/03/29/3462216d-de7b-42e5-80b2-815a54ea4773.jpg', '004600060000010103002022520260312211050230020349085102TH9104980E', '{"bank": "BBL", "date": "12 มี.ค. 69, 21:10", "memo": null, "valid": true, "amount": "2192.00", "qr_raw": "004600060000010103002022520260312211050230020349085102TH9104980E", "receiver": "ทรู มันนี่ วอลเล็ท 0049990598"}', 'processed', '2026-03-29 19:14:26.56629');
INSERT INTO public.slips VALUES (69, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/e831e56c-f669-43a5-bd33-a71634eab0e7.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:10:12.524725');
INSERT INTO public.slips VALUES (70, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/e67bf2ab-d695-49d6-bf4c-14771dd06bf3.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:10:18.987688');
INSERT INTO public.slips VALUES (71, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/dc96fa4d-0f48-4674-97a2-050a2ace2b9b.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:10:25.765494');
INSERT INTO public.slips VALUES (72, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/9fc63a02-2a74-431b-bb09-fbac93d2df85.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:10:32.518997');
INSERT INTO public.slips VALUES (73, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/2afc3110-88cb-47d0-abe6-e6a3154f1d50.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:10:39.400884');
INSERT INTO public.slips VALUES (74, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/5f1b6777-b9af-465b-b0df-2b03358ea458.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:10:46.194824');
INSERT INTO public.slips VALUES (75, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/599bab9b-2085-4c1a-925c-9b89ae2e745e.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:10:52.826222');
INSERT INTO public.slips VALUES (76, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/074cb60e-e0a5-4211-afeb-77e948d3e30d.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:17:46.576058');
INSERT INTO public.slips VALUES (77, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'ร้านถุงเงิน นำปืนผลไม้ Uten', 30.00, NULL, NULL, '2026/03/29/df1c4f86-9f1e-45d5-88f6-1e2dc5a17f22.jpg', '0041000600000101030040220016087195738APM115315102TH91042E8C', '{"bank": "KBANK", "date": "28 มี.ค. 69  19:57", "memo": null, "valid": true, "amount": "30.00", "qr_raw": "0041000600000101030040220016087195738APM115315102TH91042E8C", "receiver": "ร้านถุงเงิน นำปืนผลไม้ Uten"}', 'processed', '2026-03-29 20:17:52.681865');
INSERT INTO public.slips VALUES (78, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'ร้านถุงเงิน นำปืนผลไม้ Uten', 30.00, NULL, NULL, '2026/03/29/b42e8ed5-50fe-4234-b9ed-86b54870a10f.jpg', '0041000600000101030040220016087195738APM115315102TH91042E8C', '{"bank": "KBANK", "date": "28 มี.ค. 69  19:57", "memo": null, "valid": true, "amount": "30.00", "qr_raw": "0041000600000101030040220016087195738APM115315102TH91042E8C", "receiver": "ร้านถุงเงิน นำปืนผลไม้ Uten"}', 'processed', '2026-03-29 20:49:50.782958');
INSERT INTO public.slips VALUES (79, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/df8aebfd-b2ec-44ef-b63a-e03fbdb6a5b6.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:54:36.566509');
INSERT INTO public.slips VALUES (80, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/abe32a18-57a3-4c3c-8084-4249034aa420.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 20:57:08.883265');
INSERT INTO public.slips VALUES (81, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/9274124b-cf38-4dcc-b4a7-50e4c6c61da0.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 21:21:10.167972');
INSERT INTO public.slips VALUES (82, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/15814f08-8245-4d77-b2e7-e38d57b956c6.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 21:28:51.278777');
INSERT INTO public.slips VALUES (83, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/29/c8afd777-52f6-41f9-a61b-b64a24ff805b.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-29 22:47:55.398536');
INSERT INTO public.slips VALUES (84, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'SCB', 'นาย ธนากร ขวัญพูล', 1000.00, '2565-11-02 11:34:00', 'ชาญ', '2026/03/30/44c79fc2-c958-4ff5-be49-11c765f6a815.jpg', '0046000600000101030140225202211022XMj8r6IIId6H8WNs5102TH91040F7E', '{"bank": "SCB", "date": "02 พ.ย. 2565 11:34", "memo": "ชาญ", "valid": true, "amount": "1000.00", "qr_raw": "0046000600000101030140225202211022XMj8r6IIId6H8WNs5102TH91040F7E", "receiver": "นาย ธนากร ขวัญพูล"}', 'processed', '2026-03-30 04:59:15.668483');
INSERT INTO public.slips VALUES (85, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BBL', 'ทรู มันนี่ วอลเล็ท 0049990598', 2192.00, NULL, NULL, '2026/03/30/13088ec4-a2e4-44a6-916a-df1f2ed91677.jpg', '004600060000010103002022520260312211050230020349085102TH9104980E', '{"bank": "BBL", "date": "12 มี.ค. 69, 21:10", "memo": null, "valid": true, "amount": "2192.00", "qr_raw": "004600060000010103002022520260312211050230020349085102TH9104980E", "receiver": "ทรู มันนี่ วอลเล็ท 0049990598"}', 'processed', '2026-03-30 04:59:56.264529');
INSERT INTO public.slips VALUES (86, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KTB', 'นาย ภูริ ไชยนิคม พร้อมเพย์  x', 80.00, '2569-03-12 21:06:00', NULL, '2026/03/30/1773842e-12de-40db-81f4-e9716855eea1.jpg', '0038000600000101030060217A286cb1c2814941255102TH9104876C', '{"bank": "KTB", "date": "12 มี.ค. 2569 21:06", "memo": null, "valid": true, "amount": "80.00", "qr_raw": "0038000600000101030060217A286cb1c2814941255102TH9104876C", "receiver": "นาย ภูริ ไชยนิคม พร้อมเพย์  x"}', 'processed', '2026-03-30 05:10:46.379616');
INSERT INTO public.slips VALUES (87, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'TTB', 'calutor: utiitiยs ragroncu กาเาาณ^ด4กา.าาา', 10000.00, NULL, NULL, '2026/03/30/6be812d4-76ed-4b3d-8d7a-ebc5ecf1f5c8.jpg', NULL, '{"bank": "TTB", "date": null, "memo": null, "valid": true, "amount": "10000.00", "receiver": "calutor: utiitiยs ragroncu กาเาาณ^ด4กา.าาา"}', 'processed', '2026-03-30 05:11:16.771168');
INSERT INTO public.slips VALUES (88, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/30/2ee5f436-f198-4c1e-a079-d18be5b4e190.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-30 05:11:33.998818');
INSERT INTO public.slips VALUES (89, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KBANK', 'นาย ภูริ ไชยนิคม ธ.', 1500.00, NULL, NULL, '2026/03/30/69419d8b-92b6-4cae-bcf5-d0d916e6e5b5.jpg', '0041000600000101030040220016076141613COR044185102TH91047F99', '{"bank": "KBANK", "date": "17 มี.ค. 69 14:16", "memo": null, "valid": true, "amount": "1500.00", "qr_raw": "0041000600000101030040220016076141613COR044185102TH91047F99", "receiver": "นาย ภูริ ไชยนิคม ธ."}', 'processed', '2026-03-30 05:36:25.713152');
INSERT INTO public.slips VALUES (90, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'KTB', 'นาย ภูริ ไชยนิคม พร้อมเพย์  x', 80.00, '2569-03-12 21:06:00', NULL, '2026/03/30/174cc661-2296-4552-b3c6-2b370f966446.jpg', '0038000600000101030060217A286cb1c2814941255102TH9104876C', '{"bank": "KTB", "date": "12 มี.ค. 2569 21:06", "memo": null, "valid": true, "amount": "80.00", "qr_raw": "0038000600000101030060217A286cb1c2814941255102TH9104876C", "receiver": "นาย ภูริ ไชยนิคม พร้อมเพย์  x"}', 'processed', '2026-03-30 05:48:23.850524');
INSERT INTO public.slips VALUES (91, '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'BAY', 'สแกนตรวจสอบ', 5000.00, '2568-01-01 12:00:00', 'ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น', '2026/03/30/36b44531-1b38-4240-bfd2-5f71d5f455fe.jpg', 'http://en.m.wikipedia.org', '{"bank": "BAY", "date": "01 ม.ค. 2568 12:00", "memo": "ใบเสร็จ เพิ่มในรายการ AELE  เสร็จสิ้น", "valid": true, "amount": "5000.00", "qr_raw": "http://en.m.wikipedia.org", "receiver": "สแกนตรวจสอบ"}', 'processed', '2026-03-30 05:51:13.968366');
INSERT INTO public.slips VALUES (92, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'ร้านถุงเงิน นำปืนผลไม้ Uten', 30.00, NULL, NULL, '2026/03/30/5bc9d28d-ca1c-4438-ab2f-359b0143fdca.jpg', '0041000600000101030040220016087195738APM115315102TH91042E8C', '{"bank": "KBANK", "date": "28 มี.ค. 69  19:57", "memo": null, "valid": true, "amount": "30.00", "qr_raw": "0041000600000101030040220016087195738APM115315102TH91042E8C", "receiver": "ร้านถุงเงิน นำปืนผลไม้ Uten"}', 'processed', '2026-03-30 05:51:28.829771');
INSERT INTO public.slips VALUES (93, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/30/dbdc2657-f004-4ada-bcf8-62d2db967a44.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-30 05:58:53.50996');
INSERT INTO public.slips VALUES (94, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/30/772fae75-423e-40fe-bc9e-f268e45aeba3.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-30 06:00:15.606839');
INSERT INTO public.slips VALUES (95, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/30/28f7f61c-590b-4522-906d-5594e091db20.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-30 06:11:03.592671');
INSERT INTO public.slips VALUES (96, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KTB', 'น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์', 35.00, '2568-09-22 20:28:00', NULL, '2026/03/30/0a34d132-ac7a-4e7d-853e-6bdb542ca9b6.jpg', '0038000600000101030060217A090802d9f3e345b35102TH910463F5', '{"bank": "KTB", "date": "22 ก.ย. 2568 20:28", "memo": null, "valid": true, "amount": "35.00", "qr_raw": "0038000600000101030060217A090802d9f3e345b35102TH910463F5", "receiver": "น.ส. วราภรณ์ สมบัติสมภพ พร้อมเพย์"}', 'processed', '2026-03-30 06:48:48.295845');
INSERT INTO public.slips VALUES (97, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'ร้านถุงเงิน นำปืนผลไม้ Uten', 30.00, NULL, NULL, '2026/03/30/e49749a6-5d1b-45d2-a525-cdbe204f0bfb.jpg', '0041000600000101030040220016087195738APM115315102TH91042E8C', '{"bank": "KBANK", "date": "28 มี.ค. 69  19:57", "memo": null, "valid": true, "amount": "30.00", "qr_raw": "0041000600000101030040220016087195738APM115315102TH91042E8C", "receiver": "ร้านถุงเงิน นำปืนผลไม้ Uten"}', 'processed', '2026-03-30 06:49:14.871412');
INSERT INTO public.slips VALUES (98, 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'BBL', 'นาย ภูริ', 27.00, NULL, NULL, '2026/03/30/fdf4b23f-080a-4dc1-b05a-29971a459a29.jpg', '004600060000010103002022520260318092530240008568085102TH91044A9C', '{"bank": "BBL", "date": "18 มี.ค. 69, 09:25", "memo": null, "valid": true, "amount": "27.00", "qr_raw": "004600060000010103002022520260318092530240008568085102TH91044A9C", "receiver": "นาย ภูริ"}', 'processed', '2026-03-30 07:06:41.78007');
INSERT INTO public.slips VALUES (99, '9db8aa73-7870-4481-a109-6430ca921dd5', 'BBL', 'นาย ภูริ', 27.00, NULL, NULL, '2026/03/30/8e887e74-676f-42b6-876b-3a0142958d85.jpg', '004600060000010103002022520260318092530240008568085102TH91044A9C', '{"bank": "BBL", "date": "18 มี.ค. 69, 09:25", "memo": null, "valid": true, "amount": "27.00", "qr_raw": "004600060000010103002022520260318092530240008568085102TH91044A9C", "receiver": "นาย ภูริ"}', 'processed', '2026-03-30 07:59:34.571212');
INSERT INTO public.slips VALUES (100, '9db8aa73-7870-4481-a109-6430ca921dd5', 'BBL', 'นาย ภูริ', 27.00, NULL, NULL, '2026/03/30/0b5fb21c-b03c-4f43-b2a0-3d2bd2649c17.jpg', '004600060000010103002022520260318092530240008568085102TH91044A9C', '{"bank": "BBL", "date": "18 มี.ค. 69, 09:25", "memo": null, "valid": true, "amount": "27.00", "qr_raw": "004600060000010103002022520260318092530240008568085102TH91044A9C", "receiver": "นาย ภูริ"}', 'processed', '2026-03-30 08:47:48.220858');
INSERT INTO public.slips VALUES (101, '9db8aa73-7870-4481-a109-6430ca921dd5', 'SCB', 'นาย ธนากร ขวัญพูล', 1000.00, '2565-11-02 11:34:00', 'ชาญ', '2026/03/30/5226134d-c131-4fae-933c-bc89bd1aea73.jpg', '0046000600000101030140225202211022XMj8r6IIId6H8WNs5102TH91040F7E', '{"bank": "SCB", "date": "02 พ.ย. 2565 11:34", "memo": "ชาญ", "valid": true, "amount": "1000.00", "qr_raw": "0046000600000101030140225202211022XMj8r6IIId6H8WNs5102TH91040F7E", "receiver": "นาย ธนากร ขวัญพูล"}', 'processed', '2026-03-30 09:43:36.183297');
INSERT INTO public.slips VALUES (102, '9db8aa73-7870-4481-a109-6430ca921dd5', 'BBL', 'นาย ภูริ', 27.00, NULL, NULL, '2026/03/30/60399611-aca7-4f39-bd54-e55dca236bb2.jpg', '004600060000010103002022520260318092530240008568085102TH91044A9C', '{"bank": "BBL", "date": "18 มี.ค. 69, 09:25", "memo": null, "valid": true, "amount": "27.00", "qr_raw": "004600060000010103002022520260318092530240008568085102TH91044A9C", "receiver": "นาย ภูริ"}', 'processed', '2026-03-30 10:04:27.044718');
INSERT INTO public.slips VALUES (103, '9db8aa73-7870-4481-a109-6430ca921dd5', 'BBL', 'นาย ภูริ', 27.00, NULL, NULL, '2026/03/30/456ac62a-9544-4f26-8671-cd746a507a68.jpg', '004600060000010103002022520260318092530240008568085102TH91044A9C', '{"bank": "BBL", "date": "18 มี.ค. 69, 09:25", "memo": null, "valid": true, "amount": "27.00", "qr_raw": "004600060000010103002022520260318092530240008568085102TH91044A9C", "receiver": "นาย ภูริ"}', 'processed', '2026-03-30 10:05:03.531397');
INSERT INTO public.slips VALUES (104, '9db8aa73-7870-4481-a109-6430ca921dd5', 'BBL', 'นาย ภูริ', 27.00, NULL, NULL, '2026/03/30/274fde5c-5fcc-4166-bdb3-65eaae4c4e30.jpg', '004600060000010103002022520260318092530240008568085102TH91044A9C', '{"bank": "BBL", "date": "18 มี.ค. 69, 09:25", "memo": null, "valid": true, "amount": "27.00", "qr_raw": "004600060000010103002022520260318092530240008568085102TH91044A9C", "receiver": "นาย ภูริ"}', 'processed', '2026-03-30 10:06:44.186864');
INSERT INTO public.slips VALUES (105, '9db8aa73-7870-4481-a109-6430ca921dd5', 'BBL', 'นาย ภูริ', 27.00, NULL, NULL, '2026/03/31/100f197c-3927-4fb9-8249-447d2874e4f5.jpg', '004600060000010103002022520260318092530240008568085102TH91044A9C', '{"bank": "BBL", "date": "18 มี.ค. 69, 09:25", "memo": null, "valid": true, "amount": "27.00", "qr_raw": "004600060000010103002022520260318092530240008568085102TH91044A9C", "receiver": "นาย ภูริ"}', 'processed', '2026-03-31 09:34:31.771849');
INSERT INTO public.slips VALUES (106, '9db8aa73-7870-4481-a109-6430ca921dd5', 'KBANK', 'Rice Cb1', 42.00, NULL, NULL, '2026/04/07/20025f16-fd77-46c2-ba9c-d3bac7e9f485.jpg', '0041000600000101030040220016097103141BPM177655102TH91044757', '{"bank": "KBANK", "date": "7 เม.ย. 69  10:31", "memo": null, "valid": true, "amount": "42.00", "qr_raw": "0041000600000101030040220016097103141BPM177655102TH91044757", "receiver": "Rice Cb1"}', 'processed', '2026-04-07 07:20:56.46035');
INSERT INTO public.slips VALUES (119, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'ใช้ไป Bo', NULL, NULL, NULL, '2026/04/21/c2663358-cbbb-43fc-af6f-30c1aa521bdd.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "ใช้ไป Bo"}', 'processed', '2026-04-21 19:51:04.080101');
INSERT INTO public.slips VALUES (120, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', '21:37 น. Eะ', NULL, NULL, NULL, '2026/04/21/3460cade-605c-4ea4-8d3c-62e3a9fa6d9e.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "21:37 น. Eะ"}', 'processed', '2026-04-21 19:51:11.399023');
INSERT INTO public.slips VALUES (121, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', '21:37 น. Eะ', NULL, NULL, NULL, '2026/04/21/6b7cf357-1425-4fc0-b8aa-58b9ac00e15d.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "21:37 น. Eะ"}', 'processed', '2026-04-21 19:51:18.040774');
INSERT INTO public.slips VALUES (122, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'ดูรายละเอียดงานบน Jooble L', NULL, NULL, NULL, '2026/04/21/b4e7a5e2-4609-47b4-8e64-075cfdd4c98b.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "ดูรายละเอียดงานบน Jooble L"}', 'processed', '2026-04-21 19:51:27.123877');
INSERT INTO public.slips VALUES (123, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', '21:32 น. Ed ตี', NULL, NULL, NULL, '2026/04/21/0cb1b740-886d-46a7-bd1a-402de88ab787.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "21:32 น. Ed ตี"}', 'processed', '2026-04-21 19:51:36.570262');
INSERT INTO public.slips VALUES (124, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'ดูรายละเอียดงานบน Jooble E', NULL, NULL, NULL, '2026/04/21/d941eb0a-de8a-4b71-af2b-f4c86d6e0c43.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "ดูรายละเอียดงานบน Jooble E"}', 'processed', '2026-04-21 19:51:46.179782');
INSERT INTO public.slips VALUES (125, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', '21:31 น. Ed Dี', NULL, NULL, NULL, '2026/04/21/04b08b82-6447-43d0-a2db-850a7ea80a48.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "21:31 น. Ed Dี"}', 'processed', '2026-04-21 19:51:55.512609');
INSERT INTO public.slips VALUES (126, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'สินเชื่อบุคคล ud... เงินต้นทั้งหมด 1oo ooo.0d b เงินกู้ส่วนบุคคล  installment  emi', 11480.00, NULL, NULL, '2026/04/21/b1248508-b6b8-4b99-9c6e-b0cdcc79e9a6.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": true, "amount": "11480.00", "receiver": "สินเชื่อบุคคล ud... เงินต้นทั้งหมด 1oo ooo.0d b เงินกู้ส่วนบุคคล  installment  emi"}', 'processed', '2026-04-21 19:52:05.473984');
INSERT INTO public.slips VALUES (127, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', '*คำนวณจากฐานข้อมูลตลาด  แรงงานปี 2567', 23000.00, NULL, NULL, '2026/04/21/0aebe5b5-9331-4e24-ba04-bc933f173412.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": true, "amount": "23000.00", "receiver": "*คำนวณจากฐานข้อมูลตลาด  แรงงานปี 2567"}', 'processed', '2026-04-21 19:52:14.368768');
INSERT INTO public.slips VALUES (128, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'สแกน ocr', 14500.00, NULL, NULL, '2026/04/21/2ad5e665-fb22-4075-9142-117f8a11ca04.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": true, "amount": "14500.00", "receiver": "สแกน ocr"}', 'processed', '2026-04-21 19:52:21.996338');
INSERT INTO public.slips VALUES (129, '0f43a469-1931-4108-8d76-81f5b8604168', 'KTB', 'เชื่อบัญชี', NULL, NULL, NULL, '2026/04/26/9f04a0f9-0eff-4916-bb94-7ac02954e53d.jpg', '00020101021229370016A0000006770101110213184980121002953037645802TH630457AF', '{"bank": "KTB", "date": null, "memo": null, "valid": false, "amount": null, "qr_raw": "00020101021229370016A0000006770101110213184980121002953037645802TH630457AF", "receiver": "เชื่อบัญชี"}', 'processed', '2026-04-26 14:10:01.663024');
INSERT INTO public.slips VALUES (130, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'รายละเอียดรายเดือน 135 เดือน  คลิกที่เดือนเพื่อดูรายละเอียดของแต่ละหนี้', NULL, NULL, NULL, '2026/04/26/03db6a26-27cf-48d8-b7a8-cf2f354668b3.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "รายละเอียดรายเดือน 135 เดือน  คลิกที่เดือนเพื่อดูรายละเอียดของแต่ละหนี้"}', 'processed', '2026-04-26 14:10:12.459666');
INSERT INTO public.slips VALUES (131, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'M5O', NULL, NULL, NULL, '2026/04/26/7207054f-890d-401f-ac7d-ce2ec49633a9.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "M5O"}', 'processed', '2026-04-26 14:10:21.867752');
INSERT INTO public.slips VALUES (132, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'กราฟ', NULL, NULL, NULL, '2026/04/26/ef46d101-8ba5-4482-94b0-a6781396a345.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "กราฟ"}', 'processed', '2026-04-26 14:10:30.190781');
INSERT INTO public.slips VALUES (133, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'คณ จากกลยุทธ์ที่คุณเลือก นี่คีอระยะเวลาที่คาดการณ์ ว่าคุณจะหมดหนี้ ภายใน 135 เดือน.', NULL, NULL, NULL, '2026/04/26/bd2def22-96b5-4492-9c37-fc08787bc5dc.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": false, "amount": null, "receiver": "คณ จากกลยุทธ์ที่คุณเลือก นี่คีอระยะเวลาที่คาดการณ์ ว่าคุณจะหมดหนี้ ภายใน 135 เดือน."}', 'processed', '2026-04-26 14:10:39.626069');
INSERT INTO public.slips VALUES (134, '0f43a469-1931-4108-8d76-81f5b8604168', 'UNKNOWN', 'สินเชื่อบุคคล u... เงินต้นทั้งหมด 1oo ooo.0d b เงินกู้ส่วนบุคคล  installment emi', 1022.57, NULL, NULL, '2026/04/26/8af71c7d-1dda-4aa7-87aa-0ba6fa03a2e9.jpg', NULL, '{"bank": "UNKNOWN", "date": null, "memo": null, "valid": true, "amount": "1022.57", "receiver": "สินเชื่อบุคคล u... เงินต้นทั้งหมด 1oo ooo.0d b เงินกู้ส่วนบุคคล  installment emi"}', 'processed', '2026-04-26 14:10:48.984009');
INSERT INTO public.slips VALUES (135, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย ลัทธวิทย์ ๊ก ธ. .', 200.00, NULL, NULL, '2026/04/26/861c3e90-c885-401c-8bda-549e677aadb1.jpg', '0041000600000101030040220016116111409APP000555102TH9104654A', '{"bank": "KBANK", "date": "26 เม.ย. 69 11:14", "memo": null, "valid": true, "amount": "200.00", "qr_raw": "0041000600000101030040220016116111409APP000555102TH9104654A", "receiver": "นาย ลัทธวิทย์ ๊ก ธ. ."}', 'processed', '2026-04-26 14:12:27.907357');
INSERT INTO public.slips VALUES (136, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/fb9e16a1-c54e-4982-bbfb-fc27f70e773e.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 09:24:11.40599');
INSERT INTO public.slips VALUES (137, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/1525a361-1170-490f-9244-c2d6dc23250f.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 09:31:21.179168');
INSERT INTO public.slips VALUES (138, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/491df514-7341-4a4c-b90b-af3a4e02cec9.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 09:39:19.974507');
INSERT INTO public.slips VALUES (139, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/5d92709e-e162-4ab8-8115-8e165a03e77a.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 09:40:01.578939');
INSERT INTO public.slips VALUES (140, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/4f1421ff-a900-41cf-a9fc-7484fc4d31e3.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 10:17:27.906135');
INSERT INTO public.slips VALUES (141, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/2e2e9340-a983-4cb9-905c-e5d599015ae9.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 10:42:10.008138');
INSERT INTO public.slips VALUES (142, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/8cdfee04-a54b-4bed-847e-b3ae3ba331c1.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 10:49:36.342137');
INSERT INTO public.slips VALUES (143, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/71e1231e-40bd-411a-9279-ef3c6aab5184.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 11:02:31.168171');
INSERT INTO public.slips VALUES (144, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/a61b0ebb-d8e3-49d3-8f8f-15c6490bde70.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 11:09:44.591223');
INSERT INTO public.slips VALUES (145, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'น.ส.พิมผกา แก้วคำ ธ.', 105.00, NULL, NULL, '2026/04/27/e1745b57-9822-445c-af6a-1f0db8f75ca4.jpg', NULL, '{"bank": "KBANK", "date": "26 เม.ย. 69  15:08", "memo": null, "valid": true, "amount": "105.00", "receiver": "น.ส.พิมผกา แก้วคำ ธ."}', 'processed', '2026-04-27 11:10:32.471907');
INSERT INTO public.slips VALUES (146, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/c0404d75-7c99-4614-b813-323d21da5a9b.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 11:19:34.770363');
INSERT INTO public.slips VALUES (147, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/388a2aec-02b5-4674-b80f-5f29c9e5d95e.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 11:35:44.763341');
INSERT INTO public.slips VALUES (148, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/1c119902-39bf-4864-844a-3cb9fbc47fe3.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 11:46:12.230055');
INSERT INTO public.slips VALUES (149, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย', 56.00, NULL, NULL, '2026/04/27/62f4e5b4-373d-4900-84e7-a446bab3202f.jpg', '0041000600000101030040220016117084835BQR069285102TH9104B801', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:48", "memo": null, "valid": true, "amount": "56.00", "qr_raw": "0041000600000101030040220016117084835BQR069285102TH9104B801", "receiver": "แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย"}', 'processed', '2026-04-27 11:58:45.731555');
INSERT INTO public.slips VALUES (150, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย', 56.00, NULL, NULL, '2026/04/27/8fa828c2-6425-43fd-bafa-6bcc3b5bf015.jpg', '0041000600000101030040220016117084835BQR069285102TH9104B801', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:48", "memo": null, "valid": true, "amount": "56.00", "qr_raw": "0041000600000101030040220016117084835BQR069285102TH9104B801", "receiver": "แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย"}', 'processed', '2026-04-27 12:13:26.820861');
INSERT INTO public.slips VALUES (151, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/3283b5d9-9fbc-4a94-b189-a8f8694fc020.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 12:24:57.739693');
INSERT INTO public.slips VALUES (152, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย', 56.00, NULL, NULL, '2026/04/27/9cdfea54-5edb-4c77-a41b-9da3029dc329.jpg', '0041000600000101030040220016117084835BQR069285102TH9104B801', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:48", "memo": null, "valid": true, "amount": "56.00", "qr_raw": "0041000600000101030040220016117084835BQR069285102TH9104B801", "receiver": "แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย"}', 'processed', '2026-04-27 12:33:54.803773');
INSERT INTO public.slips VALUES (153, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย', 56.00, NULL, NULL, '2026/04/27/2bdb6840-0b54-4543-b13c-c7e4b45b5db1.jpg', '0041000600000101030040220016117084835BQR069285102TH9104B801', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:48", "memo": null, "valid": true, "amount": "56.00", "qr_raw": "0041000600000101030040220016117084835BQR069285102TH9104B801", "receiver": "แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย"}', 'processed', '2026-04-27 12:38:10.571964');
INSERT INTO public.slips VALUES (154, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/9d22e214-74cd-43eb-bc9b-26887469a580.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 13:01:34.330621');
INSERT INTO public.slips VALUES (155, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/957b7c4f-49c6-4d72-b469-2e5a7e534bf5.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 13:13:27.812167');
INSERT INTO public.slips VALUES (156, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/df36cc1d-569a-4af7-bc4e-e9879b3fb19a.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 13:40:40.177917');
INSERT INTO public.slips VALUES (157, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/819bcd97-a1f8-4c4e-b36a-b4732f5e22b8.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 13:55:45.222448');
INSERT INTO public.slips VALUES (158, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/f2d4fca5-fadf-4b23-b5db-c2584064b1a4.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 14:06:41.231111');
INSERT INTO public.slips VALUES (159, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/b3d20d01-d820-4a34-a39f-414fd64c6fdd.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 14:24:17.816062');
INSERT INTO public.slips VALUES (160, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/24aced77-a61e-4794-a39f-277792370bdf.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 14:51:08.55138');
INSERT INTO public.slips VALUES (161, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/b21606e3-ed74-42a5-8ec8-2cd1edb65669.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 15:05:31.905113');
INSERT INTO public.slips VALUES (162, '0f43a469-1931-4108-8d76-81f5b8604168', 'KBANK', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 20.00, NULL, NULL, '2026/04/27/fc6070a7-5ba2-4805-9293-7eb688787a04.jpg', '0041000600000101030040220016117082211ATF017665102TH9104C96B', '{"bank": "KBANK", "date": "27 เม.ย. 69 08:22", "memo": null, "valid": true, "amount": "20.00", "qr_raw": "0041000600000101030040220016117082211ATF017665102TH9104C96B", "receiver": "นาย พิศลย์ รุจิโรจน์สกุล ธ."}', 'processed', '2026-04-27 15:51:50.961005');
INSERT INTO public.slips VALUES (163, '0f43a469-1931-4108-8d76-81f5b8604168', 'KTB', 'นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์', 50.00, '2569-05-02 19:45:00', NULL, '2026/06/16/cdf7892d-1118-4aad-85a8-740d88c5ab18.jpg', '0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97', '{"bank": "KTB", "date": "02 พ.ค. 2569 19:45", "memo": null, "valid": true, "amount": "50.00", "qr_raw": "0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97", "receiver": "นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์"}', 'processed', '2026-06-16 21:34:20.884091');
INSERT INTO public.slips VALUES (164, '0f43a469-1931-4108-8d76-81f5b8604168', 'KTB', 'นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์', 50.00, '2569-05-02 19:45:00', NULL, '2026/06/16/cf57feb4-e676-4634-a6ee-851fd34620ab.jpg', '0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97', '{"bank": "KTB", "date": "02 พ.ค. 2569 19:45", "memo": null, "valid": true, "amount": "50.00", "qr_raw": "0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97", "receiver": "นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์"}', 'processed', '2026-06-16 21:59:36.987079');
INSERT INTO public.slips VALUES (165, '0f43a469-1931-4108-8d76-81f5b8604168', 'KTB', 'นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์', 50.00, '2569-05-02 19:45:00', NULL, '2026/06/16/0b93516a-5ddb-46c9-95a6-a92ed46860a5.jpg', '0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97', '{"bank": "KTB", "date": "02 พ.ค. 2569 19:45", "memo": null, "valid": true, "amount": "50.00", "qr_raw": "0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97", "receiver": "นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์"}', 'processed', '2026-06-16 22:02:22.38006');
INSERT INTO public.slips VALUES (166, '0f43a469-1931-4108-8d76-81f5b8604168', 'KTB', 'นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์', 50.00, '2569-05-02 19:45:00', NULL, '2026/06/16/e8bffe96-b169-40cb-bb32-cc4f1f6c7a61.jpg', '0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97', '{"bank": "KTB", "date": "02 พ.ค. 2569 19:45", "memo": null, "valid": true, "amount": "50.00", "qr_raw": "0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97", "receiver": "นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์"}', 'processed', '2026-06-16 22:54:42.819439');
INSERT INTO public.slips VALUES (167, '0f43a469-1931-4108-8d76-81f5b8604168', 'KTB', 'นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์', 50.00, '2569-05-02 19:45:00', NULL, '2026/06/16/c16803e2-e83d-47ac-889a-befe293e3de1.jpg', '0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97', '{"bank": "KTB", "date": "02 พ.ค. 2569 19:45", "memo": null, "valid": true, "amount": "50.00", "qr_raw": "0038000600000101030060217A914122fd0ff54b7b5102TH9104BE97", "receiver": "นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์"}', 'processed', '2026-06-16 23:05:48.834899');
INSERT INTO public.slips VALUES (168, '0f43a469-1931-4108-8d76-81f5b8604168', 'KTB', 'นาง สุจินดา ชัยฤทธิ์ พร้อมเพย์', 70.00, '2568-03-20 11:49:00', NULL, '2026/06/17/78d8ee74-ed41-4494-953e-d6c075fa8b90.jpg', '0038000600000101030060217Af108a51d2f9b40725102TH9104D7A7', '{"bank": "KTB", "date": "20 มี.ค. 2568 11:49", "memo": null, "valid": true, "amount": "70.00", "qr_raw": "0038000600000101030060217Af108a51d2f9b40725102TH9104D7A7", "receiver": "นาง สุจินดา ชัยฤทธิ์ พร้อมเพย์"}', 'processed', '2026-06-17 14:18:42.301456');


--
-- TOC entry 3609 (class 0 OID 16955)
-- Dependencies: 238
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.transactions VALUES ('393ccd90-19d8-443a-80db-1874922783ef', '9db8aa73-7870-4481-a109-6430ca921dd5', 299, 450, '2025-04-01 00:00:00', 'เติมน้ำมัน (มอเตอร์ไซค์)', NULL, NULL, 'ปตท', NULL, NULL);
INSERT INTO public.transactions VALUES ('787883cb-ddea-4b65-8002-470d1f951b96', '9db8aa73-7870-4481-a109-6430ca921dd5', 301, 280, '2026-04-07 00:00:00', 'ซื้อของ 7-Eleven', NULL, NULL, '7-11', NULL, NULL);
INSERT INTO public.transactions VALUES ('3e9c1dba-9ba4-4da9-b3f5-165443b6667f', '9db8aa73-7870-4481-a109-6430ca921dd5', 298, 116, '2026-04-07 00:00:00', '', NULL, NULL, 'receiver3', NULL, NULL);
INSERT INTO public.transactions VALUES ('03385727-af5e-451d-b6ca-50bcc1db9368', '9db8aa73-7870-4481-a109-6430ca921dd5', 298, 65, '2026-04-07 00:00:00', '', NULL, NULL, 'ร้านข้าวป้าแดง', NULL, NULL);
INSERT INTO public.transactions VALUES ('011d832b-4681-408f-9a6a-8d63ede967a8', '9db8aa73-7870-4481-a109-6430ca921dd5', 298, 120, '2026-04-07 00:00:00', 'กะเพราหมูกรอบ2กล่อง', NULL, NULL, 'ร้านข้าวป้าแดง', NULL, NULL);
INSERT INTO public.transactions VALUES ('d1a16215-697d-4ccc-a7e8-d769ce52e304', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 40, '2026-04-27 00:00:00', '', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('c78c8a0a-001a-4893-b4d3-92f9d119ed23', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 09:24:12.593726', '', NULL, '2026/04/27/fb9e16a1-c54e-4982-bbfb-fc27f70e773e.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('1eddf2ff-5f4a-4895-bf38-d17f9388d7d8', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 09:31:22.227014', '', NULL, '2026/04/27/1525a361-1170-490f-9244-c2d6dc23250f.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('0e26e6b8-7005-4f8b-a995-86ff6b74f0e8', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 40, '2026-04-27 00:00:00', 'noodle', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('81cecbd6-bb92-4431-98e1-3ea54eba8b31', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 09:40:02.646844', 'candy', NULL, '2026/04/27/5d92709e-e162-4ab8-8115-8e165a03e77a.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('69b034ca-97c4-4af0-939b-8f75d30aa16b', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 10:17:28.936003', 'กินขนม', NULL, '2026/04/27/4f1421ff-a900-41cf-a9fc-7484fc4d31e3.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('4ab6ce2b-b872-4985-9aa8-765bbba3d2ff', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 50, '2026-04-27 00:00:00', 'กะเพรา', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('2b0f6773-7b41-4c0f-a812-d1f8565f94f8', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 10:42:11.020442', 'หมูปิ้ง', NULL, '2026/04/27/2e2e9340-a983-4cb9-905c-e5d599015ae9.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('9dd30268-622d-4777-b8f5-c207eb93532b', '0f43a469-1931-4108-8d76-81f5b8604168', 291, 100, '2026-04-27 00:00:00', '', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('2c03fd05-a7e1-4c53-ba07-ea2580dad8ba', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 39, '2026-03-29 15:15:07.372617', 'โอนให้: นาย ชนะพล พันธุวดี  0.', NULL, '2026/03/29/652d74b5-0e5a-4958-a085-8478f450fc89.jpg', 'นาย ชนะพล พันธุวดี  0.', 'UNKNOWN', NULL);
INSERT INTO public.transactions VALUES ('9839e9c4-ff71-4f45-ae4c-c699c301165b', '0f43a469-1931-4108-8d76-81f5b8604168', 291, 289, '2026-03-05 09:31:00', 'โอนให้: ชำระสินค้าช้อปขี้', NULL, '2026/03/29/57e9efc1-5c09-45ab-bd99-4af6659b0e2f.jpg', 'ชำระสินค้าช้อปขี้', 'KTB', NULL);
INSERT INTO public.transactions VALUES ('5df48587-aabd-47d0-ad57-41cb2339abb1', '0f43a469-1931-4108-8d76-81f5b8604168', 291, 100, '2026-03-03 17:45:00', 'โอนให้: ทรู มันนี่ วอลเล็ท 0084071040', NULL, '2026/03/29/7e7430c1-c3bf-4960-bbb9-0a780d2c9a30.jpg', 'ทรู มันนี่ วอลเล็ท 0084071040', 'KTB', NULL);
INSERT INTO public.transactions VALUES ('f128ff41-db28-48ac-a94a-7e8e0932e81c', '0f43a469-1931-4108-8d76-81f5b8604168', 292, 100, '2026-03-03 17:45:00', 'โอนให้: ทรู มันนี่ วอลเล็ท 0084071040', NULL, '2026/03/29/32156ef2-692c-4578-9367-670fa5af2370.jpg', 'ทรู มันนี่ วอลเล็ท 0084071040', 'KTB', NULL);
INSERT INTO public.transactions VALUES ('e033932d-c6d9-458e-8a4d-59d24f2e56f7', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 318, 5000, '2025-01-01 12:00:00', 'โอนให้: สแกนตรวจสอบ', NULL, '2026/03/29/48b88093-dfa4-47ff-a3cb-4ca199da943c.jpg', 'สแกนตรวจสอบ', 'BAY', NULL);
INSERT INTO public.transactions VALUES ('7829e400-4f7a-4a32-8540-f828e2a8278f', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 322, 1500, '2026-03-29 20:27:19.171614', 'โอนให้: นาย ภูริ ไชยนิคม ธ.', NULL, '2026/03/29/aff586a7-0d81-42fe-aedc-9bc3a16f8b50.jpg', 'นาย ภูริ ไชยนิคม ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('93aa415a-2e89-4ed6-ae10-c8694dbb4272', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 70, '2026-03-05 18:51:00', 'โอนให้: นาง ประนอม วงค์เสน', NULL, '2026/03/29/169e7caa-7b52-4b36-a93f-400b3bec0de4.jpg', 'นาง ประนอม วงค์เสน', 'KTB', NULL);
INSERT INTO public.transactions VALUES ('3e6f878e-6870-462f-a123-d3c111a4bc93', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 318, 5000, '2025-01-01 12:00:00', 'โอนให้: สแกนตรวจสอบ', NULL, '2026/03/30/fc93a707-fc5d-4f2e-b9da-f362a2e2680c.jpg', 'สแกนตรวจสอบ', 'BAY', NULL);
INSERT INTO public.transactions VALUES ('187ae906-7c9e-4080-a233-788b06197937', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 10:49:37.352003', 'หมูปิ้ง', NULL, '2026/04/27/8cdfee04-a54b-4bed-847e-b3ae3ba331c1.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('06c7eae8-39d1-446c-9517-d97f5bb6d7ea', '0f43a469-1931-4108-8d76-81f5b8604168', 291, 100, '2026-04-27 00:00:00', '', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('bddcecf0-144a-4856-87c2-0e84a7503d92', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 319, 1500, '2026-03-30 00:48:57.252696', 'โอนให้: นาย ภูริ ไชยนิคม ธ.', NULL, '2026/03/30/76260c02-73f2-4ac9-bfed-ed5d0a6d5966.jpg', 'นาย ภูริ ไชยนิคม ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('c5620ee8-5ae9-4c7f-b305-5289fbc1e6ce', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 11:02:32.177643', 'mooping', NULL, '2026/04/27/71e1231e-40bd-411a-9279-ef3c6aab5184.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('392f1f37-0cea-4c0f-96fb-adf5b8cf78ef', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 324, 2192, '2026-03-24 00:00:00', 'errr', NULL, '2026/03/29/21cea4fa-b20d-479d-aa4c-046e524a8f0f.jpg', 'ทรู มันนี่ วอลเล็ท 0049990598', 'BBL', NULL);
INSERT INTO public.transactions VALUES ('c698f090-fb9b-4b65-9691-b7a6499c83b9', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 50, '2026-04-27 00:00:00', 'กะเพรา', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('347e86b4-5ff0-46e7-8591-c28fe3035418', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 20, '2026-04-27 11:19:35.783804', 'หมูกระทะ', NULL, '2026/04/27/c0404d75-7c99-4614-b813-323d21da5a9b.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('f1a26530-24de-4df2-aa77-7a1b92d279b2', '0f43a469-1931-4108-8d76-81f5b8604168', 291, 150, '2026-04-27 00:00:00', 'กระเป๋า', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('751a9922-3654-4483-a1c5-e97ebb966c95', '0f43a469-1931-4108-8d76-81f5b8604168', 289, 50, '2026-04-27 00:00:00', 'grab', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('5b0abfba-5e21-4d3d-86a0-0cd90ff44194', '0f43a469-1931-4108-8d76-81f5b8604168', 289, 56, '2026-04-27 11:58:46.764098', '', NULL, '2026/04/27/62f4e5b4-373d-4900-84e7-a446bab3202f.jpg', 'แกร็บแท็กซี ประเทศไทย บจก.  แกร็บแท็กซี ประเทศไทย', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('0299759b-7a30-4c5f-9c4a-18b555f4d9b9', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 60, '2026-04-27 00:00:00', 'ไข่เจียวหมูสับ', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('a8a68754-c61e-4912-9a61-901163b30a8d', '0f43a469-1931-4108-8d76-81f5b8604168', 286, 20, '2026-04-27 13:13:28.815355', '', NULL, '2026/04/27/957b7c4f-49c6-4d72-b469-2e5a7e534bf5.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('85d90716-fa97-46be-8d32-646906d1cf0d', '0f43a469-1931-4108-8d76-81f5b8604168', 289, 50, '2026-04-27 00:00:00', '', NULL, NULL, 'taxi', NULL, NULL);
INSERT INTO public.transactions VALUES ('54c2eb3a-6ff4-40c8-a0cf-dbc9adbe40c8', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 320, 1500, '2026-03-30 00:00:00', '', NULL, '2026/03/30/2ee5f436-f198-4c1e-a079-d18be5b4e190.jpg', 'นาย ภูริ ไชยนิคม ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('0c3ba0d8-d4df-49c3-89d8-b69674bc54f8', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 318, 80, '2026-03-12 21:06:00', '', NULL, '2026/03/30/174cc661-2296-4552-b3c6-2b370f966446.jpg', 'นาย ภูริ ไชยนิคม พร้อมเพย์  x', 'KTB', NULL);
INSERT INTO public.transactions VALUES ('8fe44ea8-e2e8-4c5f-9c41-4197d9997f3a', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 316, 5000, '2568-01-01 12:00:00', 'Auto-created from slip: สแกนตรวจสอบ', NULL, NULL, 'สแกนตรวจสอบ', 'BAY', 91);
INSERT INTO public.transactions VALUES ('e7d06417-8549-4c39-8d0f-b599c0b1d29d', '0f43a469-1931-4108-8d76-81f5b8604168', 293, 100, '2026-04-27 00:00:00', 'singing', NULL, NULL, '', NULL, NULL);
INSERT INTO public.transactions VALUES ('07f02b6f-2cc6-43bf-9d69-98420f0d3db3', '0f43a469-1931-4108-8d76-81f5b8604168', 290, 20, '2026-04-27 13:55:46.271335', '', NULL, '2026/04/27/819bcd97-a1f8-4c4e-b36a-b4732f5e22b8.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('f2119460-6aaf-445a-bd05-c8abfe8a55c6', '0f43a469-1931-4108-8d76-81f5b8604168', 289, 200, '2026-04-27 00:00:00', '', NULL, NULL, 'taxi', NULL, NULL);
INSERT INTO public.transactions VALUES ('3dc0e1ef-efbc-4efa-ac23-b57d1dacd985', '0f43a469-1931-4108-8d76-81f5b8604168', 293, 20, '2026-04-27 14:51:09.795015', 'singing', NULL, '2026/04/27/24aced77-a61e-4794-a39f-277792370bdf.jpg', 'นาย พิศลย์ รุจิโรจน์สกุล ธ.', 'KBANK', NULL);
INSERT INTO public.transactions VALUES ('6cf6fffc-63c8-4e4c-ae23-584ddd82c91b', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 50, '2026-05-02 19:45:00', 'นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์', NULL, '2026/06/16/c16803e2-e83d-47ac-889a-befe293e3de1.jpg', 'นางสาว เสาวลักษณ์ ประทุมมา พร้อมเพย์', 'KTB', 167);
INSERT INTO public.transactions VALUES ('161789e7-302b-4ed0-ac48-7f4469c056fc', '0f43a469-1931-4108-8d76-81f5b8604168', 288, 70, '2025-03-20 11:49:00', '', NULL, '2026/06/17/78d8ee74-ed41-4494-953e-d6c075fa8b90.jpg', 'นาง สุจินดา ชัยฤทธิ์ พร้อมเพย์', 'KTB', 168);


--
-- TOC entry 3610 (class 0 OID 16961)
-- Dependencies: 239
-- Data for Name: user_device; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.user_device VALUES ('20f18c0f-3ebb-4263-b536-1bcde9760627', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'd91JjSTKReevwpERdebFN_:APA91bEVwv9PeUSe-tFRNZ_E1v_Ax3NJwAjN9YVGlY2TqRaxNj8b1Y_kTCfy9Gop_EZcVtE61A6bkTX8UIdmo0Rdy3YFHtWwUvfm1_6nEdqX4lZYFsk399k', 'android', 'google sdk_gphone64_x86_64', true, '2026-03-29 18:59:01.968059', '2026-03-29 18:53:32.496647', '2026-03-29 18:59:01.969389', NULL, '0d1d5970-cfa4-4407-89b3-5a49d1f24509');
INSERT INTO public.user_device VALUES ('7d539e48-4ea7-4502-b6f8-18ea715860d0', '9db8aa73-7870-4481-a109-6430ca921dd5', 'fPaQksz4QNW1kyE84yWPse:APA91bGJEjRELP_9R-IpxuNmx5JXTdaoHlC4wmgTjueJ0Ksi05sYyJ4sJm3noPZbZIcF16Pwz_fZ1f2dxXpoNkzogMKSulE7OQwE4TR2TtKSgAzSyqMegAI', 'android', 'Google sdk_gphone64_x86_64', true, '2026-04-26 14:23:50.512716', '2026-04-26 07:23:50.516693', '2026-04-26 07:23:50.516723', NULL, '2e952a54-a7a3-4e5c-86ab-f95c0fa4aa6e');
INSERT INTO public.user_device VALUES ('d86ee9af-d1b9-4bb9-87d8-c39485c3ccf8', '9db8aa73-7870-4481-a109-6430ca921dd5', 'c8kxI9v6ToGjBHjikTRvId:APA91bEqlbOGwVxPTPEhvQqbRBT3WMTTpKdd6Rb1u-uSqJddWdmHGUgvVV1ThppCY9fjX6f8oAh47NKCrAl4g05RAyaNtQIbBOy-nwktxCq8qd-PYBy9sSU', 'android', 'OPPO CPH1989', false, '2026-03-30 07:40:12.924585', '2026-03-30 07:27:26.012069', '2026-03-30 08:42:34.513868', NULL, '2bf7eb99-553b-4d55-a4a5-00089a1e4954');
INSERT INTO public.user_device VALUES ('6e9f5e04-3809-4fd5-973e-7029a8e399dd', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'cZrHbB5VSTGORfFaGwJ91e:APA91bFsxtxj435GydqqKZR66hcOdJtelLdxgBhg8XNJ4N-15oOptFFMPMEVijIuxJiIWoayl6VVmusHVx-SzAyzNtM4nbjSdf9wb3-k_1k_3sbfCvBbgGk', 'android', 'google sdk_gphone64_x86_64', true, '2026-03-30 04:47:22.751039', '2026-03-30 04:47:22.751941', '2026-03-30 04:47:22.751944', NULL, '47cd0d35-3465-4714-adc9-3efea239dba1');
INSERT INTO public.user_device VALUES ('e162473f-f6a9-4e0c-9b02-77af71609158', '9db8aa73-7870-4481-a109-6430ca921dd5', 'cozc043fRQylYG-Am3CMPu:APA91bG9LCZq7FQAeZL-UL3jzFoeyaHAUHuxiyAnaCVDNU7DR532ADrmTD2qWuOn7Woev-glAvRL6-JgZ-6aWQlFg8rZL1rYPgJ3wsnbmJ_cgp26ThKBuSw', 'android', 'OPPO CPH1989', false, '2026-03-29 17:31:33.864897', '2026-03-29 17:06:18.625334', '2026-03-30 08:42:37.914095', NULL, 'c5cb0a98-b2fb-46ad-bcfc-d7ff72d17c09');
INSERT INTO public.user_device VALUES ('6ca6869e-0bd4-4a6f-870e-99894172d4a2', 'f69c0230-b36a-4029-b128-d005743a0efb', 'cjIt7FLeTRG1yT4bD02fez:APA91bH4sJwE5s9i9fsV-kl40a6Ajgh4WILkJS0ormWZUjJLxx72Guhiw83KZ7oxgL2ubSN_xbFG2_YJbzjoZXn-sxlERWrYN4FF_PQnlYpy0dqtPpcmP_I', 'android', 'OPPO CPH1989', true, '2026-02-16 12:10:39.093302', '2026-02-16 09:14:04.123372', '2026-02-16 12:10:39.096927', NULL, 'ff900466-0fc5-4dae-8f5c-261ce5bb66d7');
INSERT INTO public.user_device VALUES ('4d47c37d-f437-47b2-a7b4-39b288a21c6a', '0f43a469-1931-4108-8d76-81f5b8604168', 'dmgEKRmBQHmPn71HQjmUok:APA91bFj5pM-hA3l74CjASQUtjH8pXLNh0OiXrjbfxaPfDoCVAwmGoqB8b6tDVmfeHtTXlQpP6KGS0NljPBY2dZtZrNXWCkwAigOe96sCdUhDmJxnarPfEg', 'android', 'Google sdk_gphone64_x86_64', true, '2026-02-16 21:49:12.683448', '2026-02-16 21:49:12.71958', '2026-02-16 21:49:12.71958', NULL, '624e8f68-af53-422a-8a7f-af67c4dd200a');
INSERT INTO public.user_device VALUES ('e67ae1e2-cd89-44d6-8d71-4b55ee725109', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'duv0eRDVT_a0LpmkV-MK21:APA91bEbOUfki1_2BEpFQBun0HqyxrxD-nbsoSr0brS28LUfXgO3uFf0KApASVPnL5YSqTwCNjqI48U3im5hHCdo5hUf3-kAMK83vIQkgDxaAaNn1Bpn07o', 'android', 'Google sdk_gphone64_x86_64', false, '2026-03-17 10:12:35.741728', '2026-03-17 10:12:35.744798', '2026-03-29 19:16:12.409494', NULL, '098b53e6-2f8f-4ccd-9b60-8d4dfe38a5a3');
INSERT INTO public.user_device VALUES ('25887038-b72e-48f8-9e41-4824cb65cd74', 'f69c0230-b36a-4029-b128-d005743a0efb', 'djdHmyNPSX-WIS_nReXReL:APA91bEEtikb0vVRbSIQCXlQktwql8p_AOe5cGg7u9--aqWTnHE4KjUG5IxXl7T9bJ6LK1Gs7cIuTYCJiyer1ALbiaUzBXeSBDXpWneT-iyOr7jp9ykn40A', 'android', 'OPPO CPH1989', true, '2026-02-17 06:44:43.092683', '2026-02-17 04:34:54.571863', '2026-02-17 06:44:43.095128', NULL, 'd58822b3-f277-4636-9644-603205391d7c');
INSERT INTO public.user_device VALUES ('7379f0d8-3c91-4198-82c2-00fc560a2fcc', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'fIHT56uGSKeK7KUhz67kg3:APA91bERY3oZsvwjvv-orwoI2t0iB8MwIiaziBmZazPSi6DucxYQq-GbApnils4b2VVhw3Wuk2iVavU8CBTLQ1axx0qa0jCCF6Hug2mT5KJkOkyAwBLtVU4', 'android', 'Google sdk_gphone64_x86_64', true, '2026-03-13 10:49:35.68537', '2026-02-16 08:04:46.419632', '2026-03-13 10:49:35.687669', NULL, 'c7cd2c41-4c85-43a7-95b9-62384f6f8ddb');
INSERT INTO public.user_device VALUES ('d99af4a5-0dc3-45b3-899e-7665aa975b87', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'dN1u0bXtQUy0p8zwVffLyt:APA91bHIWfTfClMzBtsjF5eoQEvTyEZxnZghK6xH5vrYEXZ06MQ2z8wnYfK-JRNoenDnLCTCgbI3MAtXqGFLr-K2Hw1K3WkOZleOXDipRXbxU5uRWNa0NxY', 'android', 'google sdk_gphone64_x86_64', false, '2026-03-29 18:19:17.628752', '2026-03-29 18:18:14.080433', '2026-03-29 19:16:19.621228', NULL, '595fc876-e1f4-44b1-8a33-13cfaf6227b0');
INSERT INTO public.user_device VALUES ('8b182c01-e612-4b45-b05c-765c85216eaa', '9db8aa73-7870-4481-a109-6430ca921dd5', 'dFQpdpqDR86aQ8wnWYSfBg:APA91bHNvGLzSzHcAWzV6clYknejnTnTRyi7-vEpgiFKP4xR2_6u4dB8XOt1-CAQNoaiGVV6vRpeblaFTRFkZSwKqnUM8oajAmDK5f154k-uq8Y0yZcAicg', 'android', 'Google sdk_gphone64_x86_64', false, '2026-03-28 19:52:04.197827', '2026-02-16 08:05:50.466504', '2026-04-07 11:39:51.076645', NULL, '3628bdda-7baa-4560-a0b9-6ec312eb7209');
INSERT INTO public.user_device VALUES ('fc5d79f3-0ac3-4e1f-a14a-6381f12dc111', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ei13vAz7QkOjnoJERLwRN5:APA91bGtOFn43MGampCLkAz0pXq7bna6Q2uuGT09usyfI6WERxjyUtN0hBxLRzk_eJYOPN4c4wok3K634-V2Nn4pIKGbVLqUDcOM6XGievuQ6300dgt8iUo', 'android', 'google sdk_gphone64_x86_64', false, '2026-03-30 00:46:26.490405', '2026-03-30 00:46:26.50247', '2026-03-30 05:16:58.696321', NULL, 'f6dd3ff8-60e0-48a5-96f6-8b3cffd7f5c1');
INSERT INTO public.user_device VALUES ('8c226b46-c58f-4bea-8c60-c611091d5083', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'e2t_ueFwTDmgpb9xjzBao3:APA91bGaBs10NDcxX4nai1xAgXxvazT_gfuR9ScPIsDpv9pFW40NnI75_tQhx5Yz3qKmFRT7VaeB4DwDr_iFuiQoQ-2vh_Dz-4E7m-fMMGpLFCiiBsw8CWo', 'android', 'Google sdk_gphone64_x86_64', true, '2026-03-16 15:57:15.281979', '2026-03-13 10:53:18.151951', '2026-03-16 15:57:15.284315', NULL, 'acbbb26b-65ce-475a-a350-fb68c65fbed3');
INSERT INTO public.user_device VALUES ('c2605108-38d7-4193-a79b-10134e26df05', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'fu5Qn9IlRiGdC0xpzvOC8K:APA91bFNbilgLzNvwVpCXv_HBjBu_YZeW0cXxNlyFpJjiJaRrcicGgkFE6LuuCIeffoNIuUUq97QCA-4ae8DSPevVdja7xrDn1T3kF4k_LtQeDnNiIuJ85g', 'android', 'Google sdk_gphone64_x86_64', true, '2026-03-17 12:01:41.96807', '2026-03-17 11:37:18.631434', '2026-03-17 12:01:41.968994', NULL, '593cf24a-618d-493c-892b-71be5b1dcb1f');
INSERT INTO public.user_device VALUES ('431b4ce7-c163-4ac4-aed4-cb1c6159df94', '9db8aa73-7870-4481-a109-6430ca921dd5', 'ckvMXprvSteGgPtD6HFIXH:APA91bHALFaZIdtokGdZgEgJy4HR6Tw2Z2D7Uhq3hf-iHpsBivFTe1K6LJr3Myzn01azzeu3U_HcFxGHaXjaT6uz4t8sDkzQIp0H5N_EECgHHRsU9RR4Was', 'android', 'Google sdk_gphone64_x86_64', true, '2026-04-20 22:12:35.516029', '2026-03-29 23:00:41.441294', '2026-04-20 15:12:35.518406', NULL, '15881193-15a8-4f0d-ba66-d5ce44d65047');
INSERT INTO public.user_device VALUES ('ea5dd91c-953f-4f61-a0e1-db8675a04865', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'dqefuL_cQlGn-PxOo5Mu3Q:APA91bGWDX2VxfwolqJRIE2ZWWVsy5jiRlvhTgbqmjU8LHpnxA2ZtQz5U1aOEXVCkV-S2rZ6i25x1pwnxWsJMinsQ_URddIkVnckKSBZ9OIOe4H-I30uBVw', 'android', 'google sdk_gphone64_x86_64', true, '2026-03-30 05:48:03.627236', '2026-03-30 04:58:56.637837', '2026-03-30 05:48:03.627948', NULL, '25cced8e-8ab1-41e4-a1a0-969ee35f18f0');
INSERT INTO public.user_device VALUES ('b138af64-84b0-44e3-813b-77b7f17b3c11', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'dYGuhcXuSf-wgJQdEzyn44:APA91bGLzsASa3eSUbTIw2UEUJRZcQvsUzO0IL-18DLrUGj8Nfe9BDcBofnP8cUuaL147iPZyZaOFje1hW3dSY0BnIEY3oIfMheWHLJVhIAmqdxGS2DtmPU', 'android', 'google sdk_gphone64_x86_64', true, '2026-03-29 15:14:53.896567', '2026-03-29 05:03:20.741987', '2026-03-29 15:14:53.918709', NULL, '258fb9e5-b54c-4dee-a6d2-ce13e0b0fa85');
INSERT INTO public.user_device VALUES ('d3bafe32-3847-4286-ab40-4db507d30ba2', '9db8aa73-7870-4481-a109-6430ca921dd5', 'eFS9GzNcSNa7g3XBlLJTKg:APA91bGDmJdMzqAytbWkOvggS1lTz0hrHWNMwg5ltUHKYsSxT32Bb7H1g9cxBxUvK-orEsQfpKFNfrYkuYL5z1zW5LfwvhRxU5LKu-soZj9o0G0_MUrkr1Q', 'android', 'google sdk_gphone64_x86_64', false, '2026-03-29 19:49:43.457139', '2026-03-29 18:54:02.222318', '2026-03-29 23:00:50.021263', NULL, 'b7730e1e-6dfe-4f9a-ac95-539fe38f2018');
INSERT INTO public.user_device VALUES ('d07d2a25-eb24-4c39-876c-624f2c51dd07', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'ff3ZmvR9SKaou0KbgG-riG:APA91bFC5RaS9kMVcEQgd3WmWH-hP6bDBmqCVB13RKLQDWHTt3loe_MhaES-D3IUsMgqkyKp1KMNZGuAYdu13WIPCa-TtZwM9fx1S7ldjdQvKUw56H5w7jw', 'android', 'google sdk_gphone64_x86_64', true, '2026-03-29 15:50:04.848086', '2026-03-17 15:47:55.312863', '2026-03-29 15:50:04.85309', NULL, '864ed71f-edbe-4495-b452-7251d732f53b');
INSERT INTO public.user_device VALUES ('4ad5aae0-30be-4bd8-8997-c5e1b5a72706', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'dwzRe8IETTug5aELcsyLiz:APA91bHex-Kq6MgC9-u42TWqy4FOCZzl2QKCV_VNUNpFFOTOlA8Yb4pCa-J6jic8UKOTzIg7oNPiazMJ3W9JiXIiwyXb9Mh3PLo24xFPSSFKdwJFLb4TNP8', 'android', 'google sdk_gphone64_x86_64', true, '2026-03-30 00:15:10.335261', '2026-03-29 22:41:42.180316', '2026-03-30 00:15:10.34344', NULL, '783ed929-0750-44b6-ab2b-55be635be5d5');
INSERT INTO public.user_device VALUES ('23bed613-8d75-425c-a7a2-603b57f37f85', 'f69c0230-b36a-4029-b128-d005743a0efb', 'John Doe', 'John Doe', 'John Doe', true, '2026-03-29 21:51:43.895455', '2026-03-29 21:03:10.423305', '2026-03-29 21:51:43.895836', NULL, '<xsl:value-of select="system-property(''xsl:vendor'')"/><!--');
INSERT INTO public.user_device VALUES ('725cf539-2b06-46c8-9e77-b2e57a22a0e2', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'fBqaax4ZQhCMMtH5bNJa_t:APA91bGxuDtVyKxhSa0aZYj2z9GOewV7j6BxfvDvHNuvjuiLSwWzskLQc9VsjglBUsxrsQQ9x8urj-578rkWbNL50ZYFYoYI-S4ugmmhPMs9t3VRLYsbwCg', 'android', 'google sdk_gphone64_x86_64', false, '2026-03-30 00:24:57.891132', '2026-03-30 00:24:57.909035', '2026-03-30 00:40:46.616964', NULL, 'f1ddac4f-fd52-4e6b-a0fd-12a9e6c1b724');
INSERT INTO public.user_device VALUES ('e74741e1-811a-45b9-a40e-f841e113c378', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'dQRlJmm5RV2Mf6kMkOlNtm:APA91bHzo6nGm25Xqb9jhrOoSDtnwPehr3GYtDWKtmBpxo15rkbhVGjSJe706GxDvtF8G8Gi-4h5Y-TL56jakG_QGxJiq0qbKCygbrN5DzX3DB3n-64Jxq8', 'android', 'google sdk_gphone64_x86_64', true, '2026-03-29 18:34:30.471211', '2026-03-29 18:34:30.479604', '2026-03-29 18:34:30.479623', NULL, 'ace8e8e1-92cf-4a4c-b984-7f102dcf6913');
INSERT INTO public.user_device VALUES ('725be3e3-ce77-4420-bcd7-d7e94f01c870', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'c3FPty9yR9WisjwhuB5Ydo:APA91bFxdKtH0kFJlKUNW2TJdyCWK4LEDZH1FBFzXri2_Ohvb0RraoeKlK-xElFyUWkt0sJUr1qLEoKVaaizk9HtedHB9h7dA2igH68nC3w4aclJk6u6M-8', 'android', 'google sdk_gphone64_x86_64', false, '2026-03-30 04:53:23.624228', '2026-03-30 04:53:23.625278', '2026-03-30 05:16:56.466054', NULL, 'e274b259-cf78-419f-88cb-2197173a60aa');
INSERT INTO public.user_device VALUES ('61945b8d-cb2f-4a05-84aa-7c2dbd3a1425', '9db8aa73-7870-4481-a109-6430ca921dd5', 'cEbwPGqOQGuay4Pr3C5hy-:APA91bFSjJ5xhE6YqE2tIfDghwQAgV8K5YRd02FhCMVGvqifuDEv4Ly8-yWQAZkVQaf8ssqH9TQt1fnfQn9aRe87macaVX4D78PRxeEF4fxkOqMnZU7HkIc', 'android', 'OPPO CPH1989', false, '2026-03-31 09:32:08.71263', '2026-03-31 09:32:08.723219', '2026-04-07 11:35:16.300284', NULL, '018073bb-a43c-4cd0-be36-9ddc00533a7a');
INSERT INTO public.user_device VALUES ('fe826633-696e-4e4a-8bb3-a1c45ed2675a', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'ebDThFrbSeqE11SiYmlmoB:APA91bGEbQBqosa5CyiIjW2sFeb81ZQiL1gsxcg0vwyC5m7JZPdV52AZ0Go_ZY0RwTE2xuauKbyvJ26Fx05NmPJ4F53p5i2cEW57JOW94JGxM7pnL-yBu6U', 'android', 'OPPO CPH1989', true, '2026-03-30 07:00:58.131328', '2026-03-30 06:15:45.945871', '2026-03-30 07:00:58.132244', NULL, 'af71e67e-1551-4548-ae84-70b2a1b11b8c');
INSERT INTO public.user_device VALUES ('8000f63d-78ee-4cf5-9391-c1d835c68b77', '0f43a469-1931-4108-8d76-81f5b8604168', 'cGxrgmMeQ2CjFWssktw-As:APA91bE_tMxIBV93GJJbqQwurK9gm-UWrL_BOJK4-zGcoXypo_ens4n7wwlxzcX2HQ75cAhsKHK2ZPpcButedqkBHAUzqmzwi0whjnebJcgIrhRe7DFR6z4', 'android', 'OPPO CPH1989', true, '2026-04-27 14:49:57.21417', '2026-04-07 07:58:55.007827', '2026-04-27 07:49:57.21514', NULL, 'ddc7fb62-3104-490b-9511-0fb2ea6c2539');
INSERT INTO public.user_device VALUES ('578d4391-d2f5-4bcd-8c0f-1fd51327c1c5', 'fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'dgM3_NGsQeypj8-x6KHD2y:APA91bFruausr96RqGE8qyQhQ2G6FxwHsVznU98Y3Ggm3xUFdmOqDSq3LtWqi0fV_RIICAASLuolzZ9YEw5QRvrRtWp8533XkW_6cxS5fPDMQPu7dE5m_0U', 'android', 'OPPO CPH1989', true, '2026-03-30 10:53:21.76498', '2026-03-30 09:25:14.645211', '2026-03-30 10:53:21.768435', NULL, '4770b9c6-6adc-4468-b674-90ed54d380d4');
INSERT INTO public.user_device VALUES ('96d440dd-7ff7-485b-aa4a-01c8fba44a5d', '0f43a469-1931-4108-8d76-81f5b8604168', 'fYU5DdO8TxWnkRhmoSEfZL:APA91bHZ7yOEuJHvvqLA-3HAR0ieAVnuQo2Yonio7c44TqxoqEW8iKr-tRnWxsZqLCPjE_ktr3B4HdSNq3EhBkTSQQf7JHG69uWMALQdmwlsXl5Ye--UAUY', 'android', 'google sdk_gphone64_x86_64', false, '2026-04-07 00:01:35.126594', '2026-04-07 00:01:35.214713', '2026-04-27 05:42:39.200231', NULL, 'c4266e27-5b05-4e9e-9188-21c32408eceb');
INSERT INTO public.user_device VALUES ('fa933491-f884-44a1-82bc-8294e379bc02', '0f43a469-1931-4108-8d76-81f5b8604168', 'foHHI0kIR46MLMzEZ79pc1:APA91bGH2l12o2G82y3hSqim6L-v7O-A9ctxNT9WQTXtAmegUSD1I6mokq-U87mIE_kzMNIPCeco1ELSUb-X5CbPsVnh2yErdkxqV3Fapm4d18JV1nhkqs0', 'android', 'google sdk_gphone64_x86_64', false, '2026-04-06 23:41:16.719647', '2026-03-26 18:08:22.714531', '2026-04-27 05:42:48.14554', NULL, '4a7bb48f-100a-473f-967f-e8f5e25b25c3');
INSERT INTO public.user_device VALUES ('52d04b6b-d9e6-4ed6-9cf9-08c57a1cf3b3', '9db8aa73-7870-4481-a109-6430ca921dd5', 'fR99UzIZRNK52W96d9CDs0:APA91bGaQkEKktv1jQyQhufx7-xqZeG1JvpuGK-iBZwg-kRFXXj5lcA7NjZHQnMwC2w0ZC__wAHujLGQu6DntXjPTODJytjT3oXZyHzByZAe-YoPCg8bed0', 'android', 'OPPO CPH1989', true, '2026-04-07 14:50:15.025277', '2026-04-04 23:17:43.096325', '2026-04-07 07:50:15.026377', NULL, '2b386b72-a4df-420d-9c13-94a0dd4eb30b');
INSERT INTO public.user_device VALUES ('df50d701-e98d-4904-a667-b6c0d6a617b8', 'f69c0230-b36a-4029-b128-d005743a0efb', '"/><xsl:value-of select="system-property(''xsl:vendor'')"/><!--', 'John Doe', 'John Doe', true, '2026-03-29 21:51:44.008727', '2026-03-29 21:03:18.584002', '2026-03-29 21:51:44.008961', NULL, 'John Doe');
INSERT INTO public.user_device VALUES ('b59985ba-dd51-430e-997a-ae863ae20202', '9db8aa73-7870-4481-a109-6430ca921dd5', 'eGaG3EW3Qtm1lQG2VscDUg:APA91bEQMR9KcPE6U0zk4tkhkBLiXZuNQmxLXZYvrt0kpw70HM05u291YJeMQ0F_hgaDKOcKZNW0Rbv0TVt5DAUFas0zPcVeQ69hKrfsJL3STx7P-xO_Okc', 'android', 'OPPO CPH1989', false, '2026-03-30 09:02:22.429983', '2026-03-30 07:53:50.772943', '2026-03-30 09:29:15.304132', NULL, '5b89ba3a-27f3-4169-a986-881b51168cc2');
INSERT INTO public.user_device VALUES ('0cfcf065-a451-4aa7-a5b6-e3b103da3513', '1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'dyuIXrJVQqWim9dRNp3VbN:APA91bHZj8Oh0N3A07TTLoyCbQpnymAqwIT8rAUhf3udRtWCHkK2ctgxak6fT9SWfYAxtyo4k6i3pSTbRGxA77Rpjp7_kaQtgz_SrDPBZr1--tTpBymGrjQ', 'android', 'google sdk_gphone64_x86_64', true, '2026-04-02 10:54:51.911774', '2026-03-30 13:09:15.592107', '2026-04-02 10:54:51.912833', NULL, 'd0cf9c38-b058-4efe-ba99-049f7c406e0c');
INSERT INTO public.user_device VALUES ('5219d5ef-df62-4001-a2d3-e761cecbcca7', '0f43a469-1931-4108-8d76-81f5b8604168', 'cLCAHqCvTAeVGrj34C9R1s:APA91bEDxBFqjFyGD7bu5hk5T65OEmM3aai1TCm9AicqPOWTEaWnxQsppiR7Ih20xKMGE5alN4DvpmhtXZuJugWDhoybUunRZJBdsBg8prNX9gatYvspMHw', 'android', 'google sdk_gphone16k_x86_64', true, '2026-06-17 15:55:28.644103', '2026-06-16 14:31:15.60216', '2026-06-17 08:55:28.665691', NULL, 'c93af7e3-da98-4e39-9ae2-5b461f002e06');
INSERT INTO public.user_device VALUES ('5dbe225d-d804-48a7-892f-110fa0059445', '0f43a469-1931-4108-8d76-81f5b8604168', 'fQ56Ev2OTqqee3cmP5JhEE:APA91bHuEfANEBg1KHFqQUpMQBlapSVBSzn7mqQCz7qFBjoFf5ySrCyboCbX8_G_uRkEyCOSs5q7_WXBpvP2dVRAtMIC6-yFgtOG665HFUDLKEONV29NJD4', 'android', 'google sdk_gphone16k_x86_64', true, '2026-06-12 16:00:21.37103', '2026-04-07 00:25:19.696463', '2026-06-12 09:00:21.492048', NULL, '717bffe8-d57a-4592-926a-767c6c6ffb7e');


--
-- TOC entry 3611 (class 0 OID 16969)
-- Dependencies: 240
-- Data for Name: user_setting; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.user_setting VALUES ('1833291b-5b05-4e44-988a-77873efe070f', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-02-16 06:33:12.132377', '2026-02-16 06:33:12.132391', NULL, NULL);
INSERT INTO public.user_setting VALUES ('94f4b888-bf2b-44c3-8a41-3a74a83d891d', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-02-16 06:41:18.773984', '2026-02-16 06:41:18.773995', NULL, NULL);
INSERT INTO public.user_setting VALUES ('1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-02-16 06:52:03.955841', '2026-02-16 06:52:03.955852', NULL, NULL);
INSERT INTO public.user_setting VALUES ('fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-02-16 08:16:50.932855', '2026-02-16 08:16:50.93287', NULL, NULL);
INSERT INTO public.user_setting VALUES ('f69c0230-b36a-4029-b128-d005743a0efb', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-02-16 13:52:09.44662', '2026-02-16 12:29:32.322674', NULL, NULL);
INSERT INTO public.user_setting VALUES ('7d793739-90ab-4d10-9da9-02b9ae8f51cf', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 20:59:09.548376', '2026-03-29 20:59:09.548393', NULL, NULL);
INSERT INTO public.user_setting VALUES ('22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 20:59:17.610421', '2026-03-29 20:59:17.610436', NULL, NULL);
INSERT INTO public.user_setting VALUES ('26da5e42-b707-44fb-94a0-34121e8ce20f', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 20:59:30.655587', '2026-03-29 20:59:30.655615', NULL, NULL);
INSERT INTO public.user_setting VALUES ('937c2768-1626-4167-8e9c-fcfc2358e3f4', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 21:02:21.827212', '2026-03-29 21:02:21.827222', NULL, NULL);
INSERT INTO public.user_setting VALUES ('075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 21:03:51.059497', '2026-03-29 21:03:51.059501', NULL, NULL);
INSERT INTO public.user_setting VALUES ('ad077fba-5186-4b68-97e1-6c84b6901fc1', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 21:13:46.34836', '2026-03-29 21:13:46.348372', NULL, NULL);
INSERT INTO public.user_setting VALUES ('4d22eeac-ddb7-4499-88af-806d3340d8fd', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 21:19:34.885269', '2026-03-29 21:19:34.885272', NULL, NULL);
INSERT INTO public.user_setting VALUES ('7cc650c8-16c6-4937-8347-199ffb28f650', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 21:33:02.503384', '2026-03-29 21:33:02.503387', NULL, NULL);
INSERT INTO public.user_setting VALUES ('1141aa56-463c-40e8-8f86-73e18095541c', true, true, 3, '09:00:00', 'Asia/Bangkok', '2026-03-29 21:47:12.304407', '2026-03-29 21:47:12.304409', NULL, NULL);
INSERT INTO public.user_setting VALUES ('9db8aa73-7870-4481-a109-6430ca921dd5', false, true, 0, NULL, 'Asia/Bangkok', '2026-02-16 07:06:24.89737', '2026-04-07 13:42:49.768257', NULL, '');
INSERT INTO public.user_setting VALUES ('0f43a469-1931-4108-8d76-81f5b8604168', false, true, 0, '00:00:00', 'Asia/Bangkok', '2026-02-16 14:26:25.046816', '2026-06-17 07:03:54.296573', 'พนักงานไอที/กราฟิก', NULL);


--
-- TOC entry 3612 (class 0 OID 16981)
-- Dependencies: 241
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO public.users VALUES ('4d22eeac-ddb7-4499-88af-806d3340d8fd', 'John Doe', '$2a$10$2ErXoTailT8uaRNI1rt1Ne3ThCi0wCnYSdH9bU0baf0Xuy15AIUzu', '1970-01-01 00:00:00.001', 'zj{@8970*6783}zj', false, NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES ('22a2c07d-8c0d-46f9-9b64-61ddf66c55f5', 'John Doe', '$2a$10$ZxYkx9SZEUvLZUj1oDIKIeKmBCiOy24UduVh.9Htir49kyXyfyDPq', '1970-01-01 00:00:00.001', 'zaproxy@example.com''', false, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ6YXByb3h5QGV4YW1wbGUuY29tJyIsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzc0ODIwODEwLCJleHAiOjE3Nzc0MTI4MTB9.AzpXojhh2jzETNzhPZpYXhFGTIg3ubu7824BeyZGCkM', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('075ae3c4-31aa-4ea6-ae92-ba0009a9afd1', 'John Doe', '$2a$10$ZgwhfQXT/PXKuAyJZlZmQutwt6PibRleqyJ6Gx5avFE1bFP6AUcDG', '1970-01-01 00:00:00.001', 'zj{@7097*3602}zj', false, NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES ('e98f3575-5dee-4ef1-aaa2-5b5a1784e1f7', 'shevkatisart3@gmail.com', '$2a$10$ws7eq60aJ4ygKoohYLSoWOD62wH.b56s1Hcs76Ga66.MbOb9wiOSm', NULL, 'shevkatisart3@gmail.com', false, NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES ('fb009d00-8b7c-422c-9127-d2bfbd3b1e8d', 'shevkatisart2@gmail.com', '$2a$10$NL5MSWjRWpdaZjmpWUNgPuwMjr0Pr3f85G03hcv7cwWGjpZIVd6yC', NULL, 'shevkatisart2@gmail.com', true, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzaGV2a2F0aXNhcnQyQGdtYWlsLmNvbSIsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzc0ODY3OTk0LCJleHAiOjE3Nzc0NTk5OTR9.ru3jvSBfLhtIz604kFHeEJMDI9tGJQtI3b6fOEncgVY', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('ad077fba-5186-4b68-97e1-6c84b6901fc1', 'dummy1', '$2a$10$wuH0S2IvizjY7GjpgZWqY.PGFQM2pov0MRbm9usgr503uSXM8Wqni', '2000-01-01 00:00:00', 'dummy1@gmail.com', false, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkdW1teTFAZ21haWwuY29tIiwidHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NzQ4MTg4NzUsImV4cCI6MTc3NzQxMDg3NX0.WeQRDIutTxZW_e2zLpbnHyjUDaPeShoKg7dvnodXfKA', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('26da5e42-b707-44fb-94a0-34121e8ce20f', 'John Doe', '$2a$10$bf.SKmi4.k51jkFL55m9LOHvliFFZfn/Gz9z7OyaUX71AqSgNf4Oa', '1970-01-01 00:00:00.001', 'zj{@7311*9005}zj', false, NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES ('1141aa56-463c-40e8-8f86-73e18095541c', 'John Doe', '$2a$10$HqhfgyGEqG0lOyyuymElhO/PlruqhVFSD6WCDOnVX1qOqWQc/Mkk2', '1970-01-01 00:00:00.001', 'zj{@8780*4477}zj', false, NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES ('5cd2cf76-d870-462d-b82b-ca3f8ece9c97', 'phuri.chai@mail.kmutt.ac.th', '$2a$10$uDj6QQKJX0eU8mUAdio.ouf0Rj761mVNfnAd/lRqINcn.h/un/iMu', NULL, 'phuri.chai@mail.kmutt.ac.th', false, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJwaHVyaS5jaGFpQG1haWwua211dHQuYWMudGgiLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTc3MzkxNzAzNSwiZXhwIjoxNzc2NTA5MDM1fQ.7n46bYmJa-MaJuXqkHVKdAtHB5tDhtzvopBBuQiS8dY', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('7d793739-90ab-4d10-9da9-02b9ae8f51cf', 'John Doe', '$2a$10$EntX3.WAeeJ3uM74IXoiLeSCWmSsntaBqN/Kv9J58RE99ohRDB6Re', '1970-01-01 00:00:00.001', 'zaproxy@example.com', false, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ6YXByb3h5QGV4YW1wbGUuY29tIiwidHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NzQ4MjExMDIsImV4cCI6MTc3NzQxMzEwMn0.0ZEyqPeblKcupklh5pYiuCWfewPBGxgX_1aLVAWm-1k', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('7cc650c8-16c6-4937-8347-199ffb28f650', 'John Doe', '$2a$10$i3/fSCQvxpQS.kyjtVKCsuYcHcWBWv19Vh8V.FDd1ELSYxm.Bga0S', '1970-01-01 00:00:00.001', 'zj{@6871*4152}zj', false, NULL, NULL, NULL, NULL);
INSERT INTO public.users VALUES ('937c2768-1626-4167-8e9c-fcfc2358e3f4', 'zaptest', '$2a$10$o/I9sNN65jysXK814NHrueJqhLucSaryndUk0DB3N9t5ErWEoMhRu', NULL, 'zap-test@example.com', true, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ6YXAtdGVzdEBleGFtcGxlLmNvbSIsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzc0ODE4MTU2LCJleHAiOjE3Nzc0MTAxNTZ9.0b-3aiF08jr7yP4O85mCGeetHVjH-M1H8m5X1VLRzRM', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('1eabbb62-7ffb-4077-bec5-cd8ac1b75c64', 'Ikkew', NULL, NULL, 'poori547@gmail.com', true, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJwb29yaTU0N0BnbWFpbC5jb20iLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTc3NTI5Njg0OSwiZXhwIjoxNzc3ODg4ODQ5fQ.hRYxDkzrSB4l6K3EWU38DxS5L_l6oy29-obJwGUlEVw', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('9db8aa73-7870-4481-a109-6430ca921dd5', 'S', NULL, NULL, 'shevkatisart1@gmail.com', true, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzaGV2a2F0aXNhcnQxQGdtYWlsLmNvbSIsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzc3MTg4MjI3LCJleHAiOjE3Nzk3ODAyMjd9.u9-0alrIIDLCDPod0CFeLj6s12xsajdsrUkRMLhAqxk', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('f69c0230-b36a-4029-b128-d005743a0efb', 'Soranut459@gmail.com', '$2a$10$CHN.VRgLEHlcwvMwoBoVBev8YmIpNdMauf1pX9m4wUwiYZLUiihgq', NULL, 'Soranut459@gmail.com', true, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJTb3JhbnV0NDU5QGdtYWlsLmNvbSIsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzgxMDk3MjY1LCJleHAiOjE3ODM2ODkyNjV9.Jn5vEYkMnXMhmGVjUCrQItd-Eei1l2hvSljvuqb93qo', NULL, NULL, NULL);
INSERT INTO public.users VALUES ('0f43a469-1931-4108-8d76-81f5b8604168', 'soranut sangroongruang', NULL, NULL, 'soranut169@gmail.com', true, 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzb3JhbnV0MTY5QGdtYWlsLmNvbSIsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzgxNjIwMjcwLCJleHAiOjE3ODQyMTIyNzB9.mMKuQ58w2RwLjezXXva5Do2FuEoWfk8EQvkFWis7Aek', NULL, NULL, NULL);


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 216
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 415, true);


--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 221
-- Name: debt_type_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.debt_type_seq', 51, true);


--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 222
-- Name: debt_type_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.debt_type_type_id_seq', 16, true);


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 224
-- Name: job_applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.job_applications_id_seq', 16, true);


--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 228
-- Name: receiver_mappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.receiver_mappings_id_seq', 35, true);


--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 229
-- Name: repayment_history_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.repayment_history_seq', 151, true);


--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 234
-- Name: repayment_type_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.repayment_type_seq', 101, true);


--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 235
-- Name: repayment_type_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.repayment_type_type_id_seq', 1, false);


--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 237
-- Name: slips_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.slips_id_seq', 168, true);


--
-- TOC entry 3384 (class 2606 OID 16992)
-- Name: budget_per_month budget_per_month_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.budget_per_month
    ADD CONSTRAINT budget_per_month_pkey PRIMARY KEY (budget_id);


--
-- TOC entry 3386 (class 2606 OID 16994)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- TOC entry 3388 (class 2606 OID 16996)
-- Name: debt debt_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_pkey PRIMARY KEY (debt_id);


--
-- TOC entry 3390 (class 2606 OID 16998)
-- Name: debt_statement debt_statement_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_statement
    ADD CONSTRAINT debt_statement_pkey PRIMARY KEY (statement_id);


--
-- TOC entry 3394 (class 2606 OID 17000)
-- Name: debt_transactions debt_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_transactions
    ADD CONSTRAINT debt_transactions_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 3396 (class 2606 OID 17002)
-- Name: debt_type debt_type_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_type
    ADD CONSTRAINT debt_type_pkey PRIMARY KEY (type_id);


--
-- TOC entry 3398 (class 2606 OID 17004)
-- Name: job_applications job_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.job_applications
    ADD CONSTRAINT job_applications_pkey PRIMARY KEY (id);


--
-- TOC entry 3401 (class 2606 OID 17006)
-- Name: notification_log notification_log_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3405 (class 2606 OID 17008)
-- Name: notification_rule notification_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.notification_rule
    ADD CONSTRAINT notification_rule_pkey PRIMARY KEY (rule_id);


--
-- TOC entry 3407 (class 2606 OID 17010)
-- Name: receiver_mappings receiver_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.receiver_mappings
    ADD CONSTRAINT receiver_mappings_pkey PRIMARY KEY (id);


--
-- TOC entry 3409 (class 2606 OID 17012)
-- Name: repayment_plan repayment_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_plan
    ADD CONSTRAINT repayment_plan_pkey PRIMARY KEY (plan_id);


--
-- TOC entry 3411 (class 2606 OID 17014)
-- Name: repayment_plan_result repayment_plan_result_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_plan_result
    ADD CONSTRAINT repayment_plan_result_pkey PRIMARY KEY (plan_result_id);


--
-- TOC entry 3413 (class 2606 OID 17016)
-- Name: repayment_strategy repayment_strategy_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_strategy
    ADD CONSTRAINT repayment_strategy_pkey PRIMARY KEY (strategy_id);


--
-- TOC entry 3415 (class 2606 OID 17018)
-- Name: repayment_type repayment_type_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_type
    ADD CONSTRAINT repayment_type_pkey PRIMARY KEY (type_id);


--
-- TOC entry 3417 (class 2606 OID 17020)
-- Name: slips slips_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.slips
    ADD CONSTRAINT slips_pkey PRIMARY KEY (id);


--
-- TOC entry 3419 (class 2606 OID 17022)
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 3392 (class 2606 OID 17024)
-- Name: debt_statement uk_statement; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_statement
    ADD CONSTRAINT uk_statement UNIQUE (debt_id, statement_year, statement_month);


--
-- TOC entry 3422 (class 2606 OID 17026)
-- Name: user_device uki098gxls53n2il7vv1na5yfqm; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_device
    ADD CONSTRAINT uki098gxls53n2il7vv1na5yfqm UNIQUE (device_key);


--
-- TOC entry 3425 (class 2606 OID 17028)
-- Name: user_device user_device_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_device
    ADD CONSTRAINT user_device_pkey PRIMARY KEY (device_id);


--
-- TOC entry 3427 (class 2606 OID 17030)
-- Name: user_setting user_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_setting
    ADD CONSTRAINT user_setting_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3429 (class 2606 OID 17032)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3399 (class 1259 OID 17033)
-- Name: idx_log_user_time; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX idx_log_user_time ON public.notification_log USING btree (user_id, sent_at DESC);


--
-- TOC entry 3402 (class 1259 OID 17034)
-- Name: idx_rule_ref; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX idx_rule_ref ON public.notification_rule USING btree (ref_type, ref_id);


--
-- TOC entry 3403 (class 1259 OID 17035)
-- Name: idx_rule_user; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX idx_rule_user ON public.notification_rule USING btree (user_id);


--
-- TOC entry 3420 (class 1259 OID 17036)
-- Name: idx_user_device_user; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX idx_user_device_user ON public.user_device USING btree (user_id);


--
-- TOC entry 3423 (class 1259 OID 17037)
-- Name: uq_user_device_token; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX uq_user_device_token ON public.user_device USING btree (fcm_token);


--
-- TOC entry 3430 (class 2606 OID 17038)
-- Name: budget_per_month budget_per_month_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.budget_per_month
    ADD CONSTRAINT budget_per_month_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- TOC entry 3431 (class 2606 OID 17043)
-- Name: categories categories_budget_id_dk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_budget_id_dk FOREIGN KEY (budget_id) REFERENCES public.budget_per_month(budget_id) NOT VALID;


--
-- TOC entry 3432 (class 2606 OID 17048)
-- Name: categories categories_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- TOC entry 3433 (class 2606 OID 17053)
-- Name: debt debt_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_type_fk FOREIGN KEY (debt_type) REFERENCES public.debt_type(type_id) NOT VALID;


--
-- TOC entry 3434 (class 2606 OID 17058)
-- Name: debt debt_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- TOC entry 3436 (class 2606 OID 17063)
-- Name: debt_statement fk_statement_debt; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_statement
    ADD CONSTRAINT fk_statement_debt FOREIGN KEY (debt_id) REFERENCES public.debt(debt_id) ON DELETE CASCADE;


--
-- TOC entry 3437 (class 2606 OID 17068)
-- Name: debt_transactions fk_txn_debt; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_transactions
    ADD CONSTRAINT fk_txn_debt FOREIGN KEY (debt_id) REFERENCES public.debt(debt_id) ON DELETE CASCADE;


--
-- TOC entry 3438 (class 2606 OID 17073)
-- Name: receiver_mappings fktkuhgvs1b7vwjpliw3sd66l74; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.receiver_mappings
    ADD CONSTRAINT fktkuhgvs1b7vwjpliw3sd66l74 FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- TOC entry 3435 (class 2606 OID 17078)
-- Name: debt repayment_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT repayment_type_fk FOREIGN KEY (repayment_type) REFERENCES public.repayment_type(type_id);


--
-- TOC entry 3439 (class 2606 OID 17083)
-- Name: repayment_plan strategy_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_plan
    ADD CONSTRAINT strategy_id FOREIGN KEY (strategy_id) REFERENCES public.repayment_strategy(strategy_id) NOT VALID;


--
-- TOC entry 3441 (class 2606 OID 17088)
-- Name: transactions transactions_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_fk FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- TOC entry 3442 (class 2606 OID 17093)
-- Name: transactions transactions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- TOC entry 3440 (class 2606 OID 17098)
-- Name: repayment_plan user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_plan
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: root
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2026-08-06 13:18:38

--
-- PostgreSQL database dump complete
--

\unrestrict eVbgE3rwbCsneIbyb9OrO30DEM95298cBkTZMkqkuwJg5hNkhzKTxbokTaBhef9

