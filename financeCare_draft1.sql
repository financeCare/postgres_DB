--
-- PostgreSQL database dump
--

\restrict wgYAM2aCCsIeyhid3pvukOJPTe3y6XQCDDFFxs7TUl6Ywr6FBs9ImjMyJyYDQ74

-- Dumped from database version 18.0 (Debian 18.0-1.pgdg13+3)
-- Dumped by pg_dump version 18.0

-- Started on 2025-10-13 23:14:39

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 225 (class 1259 OID 16496)
-- Name: budget_per_month; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.budget_per_month (
    budget_id uuid NOT NULL,
    user_id uuid NOT NULL,
    category_id integer NOT NULL,
    amount integer NOT NULL
);


ALTER TABLE public.budget_per_month OWNER TO root;

--
-- TOC entry 223 (class 1259 OID 16463)
-- Name: categories; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    user_id uuid NOT NULL,
    category_name character varying(128) NOT NULL,
    type character varying(10) NOT NULL
);


ALTER TABLE public.categories OWNER TO root;

--
-- TOC entry 220 (class 1259 OID 16413)
-- Name: debt; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.debt (
    debt_id character varying(128) NOT NULL,
    user_id uuid,
    principal_amount integer,
    interest_rate numrange NOT NULL,
    debt_type integer,
    start_date date,
    end_date date,
    is_active boolean
);


ALTER TABLE public.debt OWNER TO root;

--
-- TOC entry 221 (class 1259 OID 16427)
-- Name: debt_type; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.debt_type (
    type_id integer NOT NULL,
    type_name character varying(128),
    "description " character varying(1024)
);


ALTER TABLE public.debt_type OWNER TO root;

--
-- TOC entry 222 (class 1259 OID 16442)
-- Name: repayment_history; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.repayment_history (
    history_id uuid NOT NULL,
    paid_date date NOT NULL,
    debt_id character varying(128) NOT NULL,
    amount_paid integer NOT NULL
);


ALTER TABLE public.repayment_history OWNER TO root;

--
-- TOC entry 224 (class 1259 OID 16477)
-- Name: transactions; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.transactions (
    transactions_id uuid NOT NULL,
    user_id uuid NOT NULL,
    category_id integer NOT NULL,
    amount integer NOT NULL,
    date date NOT NULL,
    description character varying(1028),
    type character varying(10) NOT NULL,
    create_at timestamp with time zone NOT NULL
);


ALTER TABLE public.transactions OWNER TO root;

--
-- TOC entry 219 (class 1259 OID 16391)
-- Name: users; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(320) NOT NULL,
    password_hash character varying(128) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    email_verified boolean DEFAULT false
);


ALTER TABLE public.users OWNER TO root;

--
-- TOC entry 3491 (class 0 OID 16496)
-- Dependencies: 225
-- Data for Name: budget_per_month; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3489 (class 0 OID 16463)
-- Dependencies: 223
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3486 (class 0 OID 16413)
-- Dependencies: 220
-- Data for Name: debt; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3487 (class 0 OID 16427)
-- Dependencies: 221
-- Data for Name: debt_type; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3488 (class 0 OID 16442)
-- Dependencies: 222
-- Data for Name: repayment_history; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3490 (class 0 OID 16477)
-- Dependencies: 224
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3485 (class 0 OID 16391)
-- Dependencies: 219
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: root
--



--
-- TOC entry 3330 (class 2606 OID 16504)
-- Name: budget_per_month budget_per_month_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.budget_per_month
    ADD CONSTRAINT budget_per_month_pkey PRIMARY KEY (budget_id);


--
-- TOC entry 3326 (class 2606 OID 16471)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- TOC entry 3320 (class 2606 OID 16421)
-- Name: debt debt_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_pkey PRIMARY KEY (debt_id);


--
-- TOC entry 3322 (class 2606 OID 16457)
-- Name: debt_type debt_type_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt_type
    ADD CONSTRAINT debt_type_pkey PRIMARY KEY (type_id);


--
-- TOC entry 3324 (class 2606 OID 16450)
-- Name: repayment_history repayment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_history
    ADD CONSTRAINT repayment_history_pkey PRIMARY KEY (history_id);


--
-- TOC entry 3328 (class 2606 OID 16490)
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transactions_id);


--
-- TOC entry 3316 (class 2606 OID 16403)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3318 (class 2606 OID 16401)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3336 (class 2606 OID 16510)
-- Name: budget_per_month category_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.budget_per_month
    ADD CONSTRAINT category_id FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- TOC entry 3331 (class 2606 OID 16458)
-- Name: debt debt_type; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_type FOREIGN KEY (debt_type) REFERENCES public.debt_type(type_id) NOT VALID;


--
-- TOC entry 3333 (class 2606 OID 16451)
-- Name: repayment_history repayment_history_debt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.repayment_history
    ADD CONSTRAINT repayment_history_debt_id_fkey FOREIGN KEY (debt_id) REFERENCES public.debt(debt_id);


--
-- TOC entry 3332 (class 2606 OID 16422)
-- Name: debt user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3334 (class 2606 OID 16472)
-- Name: categories user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3335 (class 2606 OID 16491)
-- Name: transactions user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3337 (class 2606 OID 16505)
-- Name: budget_per_month user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.budget_per_month
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2025-10-13 23:14:41

--
-- PostgreSQL database dump complete
--

\unrestrict wgYAM2aCCsIeyhid3pvukOJPTe3y6XQCDDFFxs7TUl6Ywr6FBs9ImjMyJyYDQ74

