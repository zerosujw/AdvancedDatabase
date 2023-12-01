PGDMP  7    +            
    {            sales_db    16.1    16.1     	           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            
           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    16398    sales_db    DATABASE     �   CREATE DATABASE sales_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Chinese (Simplified)_China.936';
    DROP DATABASE sales_db;
                postgres    false            �            1255    16449    log_new_order()    FUNCTION     �   CREATE FUNCTION public.log_new_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO "order_audit"(operation, order_id, audit_timestamp)
    VALUES ('I', NEW.order_id, CURRENT_TIMESTAMP);
    RETURN NEW;
END
$$;
 &   DROP FUNCTION public.log_new_order();
       public          postgres    false            �            1255    16451    prevent_phantom_product()    FUNCTION     P  CREATE FUNCTION public.prevent_phantom_product() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.product_id NOT IN (SELECT product_id FROM "Products") THEN
        RAISE EXCEPTION 'Product does not exist.';

        DELETE FROM "OrderDetails"
        WHERE product_id = NEW.product_id;
    END IF;
	RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.prevent_phantom_product();
       public          postgres    false            �            1259    16399 	   Consumers    TABLE     w   CREATE TABLE public."Consumers" (
    consumer_id integer NOT NULL,
    name text,
    email text,
    address text
);
    DROP TABLE public."Consumers";
       public         heap    postgres    false            �            1259    16418    OrderDetails    TABLE     �   CREATE TABLE public."OrderDetails" (
    order_detail_id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer
);
 "   DROP TABLE public."OrderDetails";
       public         heap    postgres    false            �            1259    16413    Orders    TABLE     n   CREATE TABLE public."Orders" (
    order_id integer NOT NULL,
    consumer_id integer,
    order_date date
);
    DROP TABLE public."Orders";
       public         heap    postgres    false            �            1259    16406    Products    TABLE     f   CREATE TABLE public."Products" (
    product_id integer NOT NULL,
    name text,
    price numeric
);
    DROP TABLE public."Products";
       public         heap    postgres    false            �            1259    16439    order_audit    TABLE     �   CREATE TABLE public.order_audit (
    audit_id integer NOT NULL,
    operation character(1),
    order_id integer,
    audit_timestamp timestamp without time zone
);
    DROP TABLE public.order_audit;
       public         heap    postgres    false            �            1259    16438    order_audit_audit_id_seq    SEQUENCE     �   CREATE SEQUENCE public.order_audit_audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.order_audit_audit_id_seq;
       public          postgres    false    220                       0    0    order_audit_audit_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.order_audit_audit_id_seq OWNED BY public.order_audit.audit_id;
          public          postgres    false    219            b           2604    16442    order_audit audit_id    DEFAULT     |   ALTER TABLE ONLY public.order_audit ALTER COLUMN audit_id SET DEFAULT nextval('public.order_audit_audit_id_seq'::regclass);
 C   ALTER TABLE public.order_audit ALTER COLUMN audit_id DROP DEFAULT;
       public          postgres    false    220    219    220                      0    16399 	   Consumers 
   TABLE DATA           H   COPY public."Consumers" (consumer_id, name, email, address) FROM stdin;
    public          postgres    false    215   �#                 0    16418    OrderDetails 
   TABLE DATA           Y   COPY public."OrderDetails" (order_detail_id, order_id, product_id, quantity) FROM stdin;
    public          postgres    false    218   z$                 0    16413    Orders 
   TABLE DATA           E   COPY public."Orders" (order_id, consumer_id, order_date) FROM stdin;
    public          postgres    false    217   %                 0    16406    Products 
   TABLE DATA           =   COPY public."Products" (product_id, name, price) FROM stdin;
    public          postgres    false    216   `%                 0    16439    order_audit 
   TABLE DATA           U   COPY public.order_audit (audit_id, operation, order_id, audit_timestamp) FROM stdin;
    public          postgres    false    220   �%                  0    0    order_audit_audit_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.order_audit_audit_id_seq', 2, true);
          public          postgres    false    219            d           2606    16405    Consumers Consumers_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public."Consumers"
    ADD CONSTRAINT "Consumers_pkey" PRIMARY KEY (consumer_id);
 F   ALTER TABLE ONLY public."Consumers" DROP CONSTRAINT "Consumers_pkey";
       public            postgres    false    215            j           2606    16422    OrderDetails OrderDetails_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "OrderDetails_pkey" PRIMARY KEY (order_detail_id);
 L   ALTER TABLE ONLY public."OrderDetails" DROP CONSTRAINT "OrderDetails_pkey";
       public            postgres    false    218            h           2606    16417    Orders Orders_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "Orders_pkey" PRIMARY KEY (order_id);
 @   ALTER TABLE ONLY public."Orders" DROP CONSTRAINT "Orders_pkey";
       public            postgres    false    217            f           2606    16412    Products Products_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "Products_pkey" PRIMARY KEY (product_id);
 D   ALTER TABLE ONLY public."Products" DROP CONSTRAINT "Products_pkey";
       public            postgres    false    216            l           2606    16444    order_audit order_audit_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.order_audit
    ADD CONSTRAINT order_audit_pkey PRIMARY KEY (audit_id);
 F   ALTER TABLE ONLY public.order_audit DROP CONSTRAINT order_audit_pkey;
       public            postgres    false    220            q           2620    16452 '   OrderDetails order_details_after_insert    TRIGGER     �   CREATE TRIGGER order_details_after_insert AFTER INSERT ON public."OrderDetails" FOR EACH ROW EXECUTE FUNCTION public.prevent_phantom_product();
 B   DROP TRIGGER order_details_after_insert ON public."OrderDetails";
       public          postgres    false    218    222            p           2620    16450    Orders orders_after_insert    TRIGGER     y   CREATE TRIGGER orders_after_insert AFTER INSERT ON public."Orders" FOR EACH ROW EXECUTE FUNCTION public.log_new_order();
 5   DROP TRIGGER orders_after_insert ON public."Orders";
       public          postgres    false    217    221            n           2606    16428 '   OrderDetails OrderDetails_order_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "OrderDetails_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public."Orders"(order_id) NOT VALID;
 U   ALTER TABLE ONLY public."OrderDetails" DROP CONSTRAINT "OrderDetails_order_id_fkey";
       public          postgres    false    217    4712    218            o           2606    16433 )   OrderDetails OrderDetails_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "OrderDetails_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public."Products"(product_id) NOT VALID;
 W   ALTER TABLE ONLY public."OrderDetails" DROP CONSTRAINT "OrderDetails_product_id_fkey";
       public          postgres    false    4710    218    216            m           2606    16423    Orders Orders_consumer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "Orders_consumer_id_fkey" FOREIGN KEY (consumer_id) REFERENCES public."Consumers"(consumer_id) NOT VALID;
 L   ALTER TABLE ONLY public."Orders" DROP CONSTRAINT "Orders_consumer_id_fkey";
       public          postgres    false    4708    215    217               �   x�=���0뻏�ĳvBHGEKsN�8�,'.��`Q�l1�jw�j�V��'��(:���C'�DYY���hM�\(q�ZɊT�Vw���į�Ȧ�;��&<���Dy�T��y6<���3.�i��h��Y2���h��]=D         w   x�N�1��a^����.��EED�c����<!�k���y�]<�f��ּ���B-J�Ѡʠ3�8�B��y�ߴ!���C�A���	��RYE�NUP�ɖ�EuPL?�|i         O   x�Mǻ�0D�X�3��?���A��*��&5ך�&�v0#O'�v�c�n�ڛ'��zyv�X�ݺ�덲\潀0V �         u   x���
�0��>�>��?�w�z�*x�`C����5�f*�����?h5�'�ǨOt�Z�$��^|���q�����??��Y��Dg�:�˒P���2�ƒY�� � �         /   x�3���44�4202�54�52U04�26�20׳02�44����� ���     