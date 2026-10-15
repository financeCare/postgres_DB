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

--
-- TOC entry 3586 (class 0 OID 16871)
-- Dependencies: 215
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: root
--

--
-- TOC entry 3588 (class 0 OID 16875)
-- Dependencies: 217
-- Data for Name: debt; Type: TABLE DATA; Schema: public; Owner: root
--

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

--
-- TOC entry 3596 (class 0 OID 16907)
-- Dependencies: 225
-- Data for Name: notification_log; Type: TABLE DATA; Schema: public; Owner: root
--

--
-- TOC entry 3597 (class 0 OID 16913)
-- Dependencies: 226
-- Data for Name: notification_rule; Type: TABLE DATA; Schema: public; Owner: root
--

--
-- TOC entry 3598 (class 0 OID 16924)
-- Dependencies: 227
-- Data for Name: receiver_mappings; Type: TABLE DATA; Schema: public; Owner: root
--

--
-- TOC entry 3601 (class 0 OID 16929)
-- Dependencies: 230
-- Data for Name: repayment_plan; Type: TABLE DATA; Schema: public; Owner: root
--

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

--
-- TOC entry 3609 (class 0 OID 16955)
-- Dependencies: 238
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: root
--

--
-- TOC entry 3610 (class 0 OID 16961)
-- Dependencies: 239
-- Data for Name: user_device; Type: TABLE DATA; Schema: public; Owner: root
--

--
-- TOC entry 3611 (class 0 OID 16969)
-- Dependencies: 240
-- Data for Name: user_setting; Type: TABLE DATA; Schema: public; Owner: root
--

--
-- TOC entry 3612 (class 0 OID 16981)
-- Dependencies: 241
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: root
--

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

