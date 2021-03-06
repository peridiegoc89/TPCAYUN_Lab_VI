USE [CuentaCorrienteDBV3]
GO
/****** Object:  UserDefinedFunction [dbo].[ListadoOperacionesReporte3]    Script Date: 10/11/2019 21:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ListadoOperacionesReporte3](@idCliente int)
	RETURNS @table TABLE(saldo real,
						operacion varchar(10),
						fecha date)
	AS
	BEGIN
		insert into @table
		select monto_pago,'Pago',fecha
		from Pagos
		where id_cliente=@idCliente
	
		insert into @table
		select saldo_actualizado - saldo ,'Recargo',fecha
		from ActualizacionesImporte
		where id_cliente=@idCliente
	
		insert into @table
		select monto_total,'Compra',fecha
		from ventas
		where id_cliente=@idCliente
	
		RETURN 
	END
GO
/****** Object:  UserDefinedFunction [dbo].[ListadoReporte1]    Script Date: 10/11/2019 21:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ListadoReporte1]()
	RETURNS @table TABLE(idCliente int,
						nombre VARCHAR(50),
						apellido VARCHAR(50),
						num_doc int ,
						saldo real,
						estado VARCHAR (50),
						sumCompra real,
						sumPago real
						)
	AS
	BEGIN
		INSERT INTO @table (idCliente,nombre,apellido,num_doc,saldo, estado, sumCompra)
		SELECT * FROM clientesEstados
	
		UPDATE @table SET sumPago = (SELECT  SUM(p.monto_pago) 'pa'
									FROM Clientes c JOIN  Pagos p ON p.id_cliente = c.id_cliente
									GROUP BY c.id_cliente)
	
		RETURN 
	END
GO
/****** Object:  UserDefinedFunction [dbo].[ListadoReporte4]    Script Date: 10/11/2019 21:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ListadoReporte4](@idRubro int)
	RETURNS @table TABLE(articulo VARCHAR(50),
						cantV int ,
						totalV int,
						cantC int
						)
	AS
	BEGIN
		INSERT INTO @table (articulo,cantV,totalV,cantC)
		SELECT a.articulo,COUNT(a.articulo),
		sum(d.cantidad),
		count (distinct id_cliente)
		FROM Articulos a join Rubros r on a.id_rubro=r.id_rubro 
				join DetallesVenta d on d.id_articulo=a.id_articulo
				join Ventas v on v.id_venta=d.id_venta
		WHERE r.id_rubro=@idRubro
		GROUP BY a.articulo
	
		RETURN 
	END
GO
/****** Object:  UserDefinedFunction [dbo].[obtenerAticulosPorId]    Script Date: 10/11/2019 21:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[obtenerAticulosPorId](@idArticulo int)
		RETURNS @tabla table(id_articulo int,
							articulo varchar(50),
							precio real,
							stock int,
							imagen varchar(50),
							id_rubro int,
							rubro varchar(50),
							descripcion varchar(50)
							)
		AS
		BEGIN
				INSERT INTO @tabla SELECT a.id_articulo, a.articulo, a.precio, a.stock, a.imagen, r.id_rubro, r.rubro, a.descripcion
				FROM Articulos a JOIN Rubros r ON a.id_rubro = r.id_rubro
				WHERE id_articulo = @idArticulo
				return 
		END
GO
/****** Object:  UserDefinedFunction [dbo].[obtenerClientePorId]    Script Date: 10/11/2019 21:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[obtenerClientePorId](@idCliente int)
		RETURNS @tabla table(id_cliente int,nombre varchar(50),apellido varchar(50),domicilio varchar(50),telefono bigint,saldo real,num_doc int)
		AS
		BEGIN
		INSERT INTO @tabla SELECT id_cliente,nombre,apellido,domicilio,telefono,saldo,num_doc
		FROM Clientes WHERE id_cliente=@idCliente
		RETURN
		END
GO
/****** Object:  UserDefinedFunction [dbo].[obtenerRubroPorId]    Script Date: 10/11/2019 21:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[obtenerRubroPorId](@idRubro int)
		RETURNS @tabla table(id_rubro int,
							rubro varchar(50)
							)
		AS
		BEGIN
				INSERT INTO @tabla SELECT id_rubro, rubro 
				FROM Rubros 
				WHERE id_rubro = @idRubro
				return 
		END
GO
/****** Object:  Table [dbo].[Clientes]    Script Date: 10/11/2019 21:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clientes](
	[id_cliente] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) NULL,
	[apellido] [varchar](50) NULL,
	[domicilio] [varchar](50) NULL,
	[telefono] [bigint] NULL,
	[saldo] [real] NULL,
	[num_doc] [int] NULL,
 CONSTRAINT [PK_Clientes] PRIMARY KEY CLUSTERED 
(
	[id_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pagos]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pagos](
	[id_pago] [int] IDENTITY(1,1) NOT NULL,
	[monto_pago] [real] NULL,
	[fecha] [date] NULL,
	[id_cliente] [int] NULL,
 CONSTRAINT [PK_Pagos] PRIMARY KEY CLUSTERED 
(
	[id_pago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[reporte2]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[reporte2] AS
		SELECT c.nombre, c.apellido, p.monto_pago, p.fecha 
		FROM Pagos p JOIN Clientes c ON p.id_cliente = c.id_cliente
		WHERE p.fecha >= DATEADD(DAY, -30, GETDATE()) 
GO
/****** Object:  Table [dbo].[Ventas]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ventas](
	[id_venta] [int] IDENTITY(1,1) NOT NULL,
	[fecha] [date] NULL,
	[monto_total] [real] NULL,
	[id_cliente] [int] NULL,
 CONSTRAINT [PK_Ventas] PRIMARY KEY CLUSTERED 
(
	[id_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[clientesEstados]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[clientesEstados] AS
				SELECT c.id_cliente, c.nombre, c.apellido, c.num_doc, c.saldo, 'CANCELADO' estado , suma.s
				FROM Clientes c JOIN Ventas v ON v.id_cliente = c.id_cliente JOIN (SELECT c.id_cliente, SUM(v.monto_total) 's'
				FROM Ventas v JOIN Clientes c ON v.id_cliente=c.id_cliente 
				GROUP BY c.id_cliente) suma ON suma.id_cliente = c.id_cliente
				WHERE c.saldo = 0 
				group by c.id_cliente, c.nombre, c.apellido, c.num_doc, c.saldo , suma.s
				UNION
				SELECT c.id_cliente, c.nombre, c.apellido, c.num_doc, c.saldo, 'DEBE' estado , suma.s
				FROM Clientes c JOIN Ventas v ON v.id_cliente = c.id_cliente JOIN (SELECT c.id_cliente, SUM(v.monto_total) 's'
				FROM Ventas v JOIN Clientes c ON v.id_cliente=c.id_cliente 
				GROUP BY c.id_cliente) suma ON suma.id_cliente = c.id_cliente
				WHERE c.saldo > 0 
				group by c.id_cliente, c.nombre, c.apellido, c.num_doc, c.saldo , suma.s
GO
/****** Object:  View [dbo].[reporte1]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[reporte1] AS
	SELECT c.nombre, c.apellido, c.saldo, IIF(c.saldo = 0, 'CANCELADO', 'DEBE') estado, SUM(p.monto_pago) sumCompras, SUM(v.monto_total) sumPagos
	FROM Clientes c JOIN Pagos p ON p.id_cliente = c.id_cliente JOIN Ventas v ON v.id_cliente = c.id_cliente
	GROUP BY c.nombre, c.apellido, c.saldo;
GO
/****** Object:  Table [dbo].[Catalogos]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Catalogos](
	[id_catalogo] [int] IDENTITY(1,1) NOT NULL,
	[fecha_inicio] [date] NULL,
	[fecha_fin] [date] NULL,
	[descripcion] [varchar](50) NULL,
 CONSTRAINT [PK_Catalogos] PRIMARY KEY CLUSTERED 
(
	[id_catalogo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CatalogosVigente]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CatalogosVigente] AS
SELECT c.id_catalogo, c.fecha_inicio, c.fecha_fin, c.descripcion 
FROM Catalogos c 
WHERE c.fecha_fin >= GETDATE()
GO
/****** Object:  Table [dbo].[Articulos]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articulos](
	[id_articulo] [int] IDENTITY(1,1) NOT NULL,
	[articulo] [varchar](50) NULL,
	[precio] [real] NULL,
	[stock] [varchar](50) NULL,
	[imagen] [varchar](50) NULL,
	[id_rubro] [int] NULL,
	[descripcion] [varchar](100) NULL,
 CONSTRAINT [PK_Articulos] PRIMARY KEY CLUSTERED 
(
	[id_articulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rubros]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rubros](
	[id_rubro] [int] IDENTITY(1,1) NOT NULL,
	[rubro] [varchar](50) NULL,
 CONSTRAINT [PK_Rubros] PRIMARY KEY CLUSTERED 
(
	[id_rubro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[obtenerArticulos]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[obtenerArticulos] AS
SELECT a.id_articulo, a.articulo, a.precio, a.stock, a.imagen, r.id_rubro, r.rubro, a.descripcion
FROM Articulos a JOIN Rubros r ON a.id_rubro = r.id_rubro;
GO
/****** Object:  View [dbo].[articulosEnStock]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[articulosEnStock] AS
	SELECT a.id_articulo, a.articulo, a.precio, a.stock, a.imagen, r.id_rubro, r.rubro, a.descripcion
	FROM Articulos a JOIN Rubros r ON a.id_rubro = r.id_rubro 
	WHERE a.stock > 0 
GO
/****** Object:  View [dbo].[obtenerRubros]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [dbo].[obtenerRubros] AS
	SELECT rubro
	FROM Rubros
GO
/****** Object:  View [dbo].[obtenerClientes]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		CREATE VIEW [dbo].[obtenerClientes] AS
		SELECT id_cliente,nombre,apellido,domicilio,telefono,saldo
		FROM Clientes
GO
/****** Object:  View [dbo].[clientesConDeudas]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[clientesConDeudas] AS
SELECT id_cliente,nombre,apellido,domicilio,telefono,saldo 
FROM Clientes WHERE saldo > 0 
GO
/****** Object:  Table [dbo].[ActualizacionesImporte]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActualizacionesImporte](
	[id_importe] [int] IDENTITY(1,1) NOT NULL,
	[fecha] [date] NULL,
	[porcentaje] [real] NULL,
	[saldo] [real] NULL,
	[saldo_actualizado] [real] NULL,
	[id_cliente] [int] NULL,
 CONSTRAINT [PK_ActualizacionesImporte] PRIMARY KEY CLUSTERED 
(
	[id_importe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DetallesCatalogo]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetallesCatalogo](
	[id_articulo] [int] NULL,
	[id_catalogo] [int] NULL,
	[id_detalle_catalogo] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_DetallesCatalogo] PRIMARY KEY CLUSTERED 
(
	[id_detalle_catalogo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DetallesVenta]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetallesVenta](
	[id_detalle_v] [int] IDENTITY(1,1) NOT NULL,
	[id_articulo] [int] NULL,
	[cantidad] [int] NULL,
	[precio_unitario] [real] NULL,
	[id_venta] [int] NULL,
 CONSTRAINT [PK_DetallesVenta] PRIMARY KEY CLUSTERED 
(
	[id_detalle_v] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuarios]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuarios](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_name] [varchar](50) NULL,
	[password] [varchar](50) NULL,
 CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Articulos] ON 

INSERT [dbo].[Articulos] ([id_articulo], [articulo], [precio], [stock], [imagen], [id_rubro], [descripcion]) VALUES (1, N'Fernet', 399, N'200', N'img_fernet.jpg', 2, N'Fernet Branca')
INSERT [dbo].[Articulos] ([id_articulo], [articulo], [precio], [stock], [imagen], [id_rubro], [descripcion]) VALUES (2, N'Aceite', 150, N'500', N'img_aceite.jpg', 1, N'Aceite Cañuelas')
INSERT [dbo].[Articulos] ([id_articulo], [articulo], [precio], [stock], [imagen], [id_rubro], [descripcion]) VALUES (3, N'Cerveza', 80, N'5', N'3100629_l.jpg', 2, N'Andes Rubia')
INSERT [dbo].[Articulos] ([id_articulo], [articulo], [precio], [stock], [imagen], [id_rubro], [descripcion]) VALUES (6, N'Neumatico', 5000, N'300', N'neumatico.jpg', 1, N'Firestone')
INSERT [dbo].[Articulos] ([id_articulo], [articulo], [precio], [stock], [imagen], [id_rubro], [descripcion]) VALUES (7, N'Desodorante Axe', 150, N'1000', N'desodorante.jpg', 1, N'River Plate edition')
SET IDENTITY_INSERT [dbo].[Articulos] OFF
SET IDENTITY_INSERT [dbo].[Catalogos] ON 

INSERT [dbo].[Catalogos] ([id_catalogo], [fecha_inicio], [fecha_fin], [descripcion]) VALUES (1, CAST(N'3919-02-01' AS Date), CAST(N'3919-02-01' AS Date), N'no tengo descripción')
SET IDENTITY_INSERT [dbo].[Catalogos] OFF
SET IDENTITY_INSERT [dbo].[Clientes] ON 

INSERT [dbo].[Clientes] ([id_cliente], [nombre], [apellido], [domicilio], [telefono], [saldo], [num_doc]) VALUES (1, N'Franco', N'Armani', N'Cozy Bend 7512 ', 351123123, 0, 33777000)
INSERT [dbo].[Clientes] ([id_cliente], [nombre], [apellido], [domicilio], [telefono], [saldo], [num_doc]) VALUES (2, N'Gonzalo', N'Martinez', N'Silent Autumn Carrefour 1342', 351222333, 5150, 33666000)
INSERT [dbo].[Clientes] ([id_cliente], [nombre], [apellido], [domicilio], [telefono], [saldo], [num_doc]) VALUES (3, N'Paulo', N'Díaz', N'Rustic Pond 523', 297122332, 0, 33555222)
INSERT [dbo].[Clientes] ([id_cliente], [nombre], [apellido], [domicilio], [telefono], [saldo], [num_doc]) VALUES (4, N'Marcelo', N'Gallardo', N'Nuñes', 11223223, 230, 111222333)
SET IDENTITY_INSERT [dbo].[Clientes] OFF
SET IDENTITY_INSERT [dbo].[DetallesCatalogo] ON 

INSERT [dbo].[DetallesCatalogo] ([id_articulo], [id_catalogo], [id_detalle_catalogo]) VALUES (1, 1, 1)
INSERT [dbo].[DetallesCatalogo] ([id_articulo], [id_catalogo], [id_detalle_catalogo]) VALUES (2, 1, 2)
INSERT [dbo].[DetallesCatalogo] ([id_articulo], [id_catalogo], [id_detalle_catalogo]) VALUES (3, 1, 3)
INSERT [dbo].[DetallesCatalogo] ([id_articulo], [id_catalogo], [id_detalle_catalogo]) VALUES (6, 1, 4)
INSERT [dbo].[DetallesCatalogo] ([id_articulo], [id_catalogo], [id_detalle_catalogo]) VALUES (7, 1, 5)
SET IDENTITY_INSERT [dbo].[DetallesCatalogo] OFF
SET IDENTITY_INSERT [dbo].[DetallesVenta] ON 

INSERT [dbo].[DetallesVenta] ([id_detalle_v], [id_articulo], [cantidad], [precio_unitario], [id_venta]) VALUES (1, 6, 1, 5000, 1)
INSERT [dbo].[DetallesVenta] ([id_detalle_v], [id_articulo], [cantidad], [precio_unitario], [id_venta]) VALUES (2, 7, 1, 150, 1)
INSERT [dbo].[DetallesVenta] ([id_detalle_v], [id_articulo], [cantidad], [precio_unitario], [id_venta]) VALUES (3, 2, 1, 150, 2)
INSERT [dbo].[DetallesVenta] ([id_detalle_v], [id_articulo], [cantidad], [precio_unitario], [id_venta]) VALUES (4, 3, 1, 80, 2)
SET IDENTITY_INSERT [dbo].[DetallesVenta] OFF
SET IDENTITY_INSERT [dbo].[Rubros] ON 

INSERT [dbo].[Rubros] ([id_rubro], [rubro]) VALUES (1, N'Almacén')
INSERT [dbo].[Rubros] ([id_rubro], [rubro]) VALUES (2, N'Bebidas')
INSERT [dbo].[Rubros] ([id_rubro], [rubro]) VALUES (3, N'Fresco')
INSERT [dbo].[Rubros] ([id_rubro], [rubro]) VALUES (4, N'Perfumería')
INSERT [dbo].[Rubros] ([id_rubro], [rubro]) VALUES (5, N'Limpieza')
INSERT [dbo].[Rubros] ([id_rubro], [rubro]) VALUES (6, N'Automotor')
SET IDENTITY_INSERT [dbo].[Rubros] OFF
SET IDENTITY_INSERT [dbo].[Usuarios] ON 

INSERT [dbo].[Usuarios] ([id], [user_name], [password]) VALUES (1, N'admin', N'123')
SET IDENTITY_INSERT [dbo].[Usuarios] OFF
SET IDENTITY_INSERT [dbo].[Ventas] ON 

INSERT [dbo].[Ventas] ([id_venta], [fecha], [monto_total], [id_cliente]) VALUES (1, CAST(N'3919-12-10' AS Date), 5150, 2)
INSERT [dbo].[Ventas] ([id_venta], [fecha], [monto_total], [id_cliente]) VALUES (2, CAST(N'3919-12-10' AS Date), 230, 4)
SET IDENTITY_INSERT [dbo].[Ventas] OFF
/****** Object:  Index [IX_Clientes_num_doc]    Script Date: 10/11/2019 21:49:57 ******/
ALTER TABLE [dbo].[Clientes] ADD  CONSTRAINT [IX_Clientes_num_doc] UNIQUE NONCLUSTERED 
(
	[num_doc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Usuarios]    Script Date: 10/11/2019 21:49:57 ******/
ALTER TABLE [dbo].[Usuarios] ADD  CONSTRAINT [IX_Usuarios] UNIQUE NONCLUSTERED 
(
	[user_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Clientes] ADD  DEFAULT ((0)) FOR [saldo]
GO
ALTER TABLE [dbo].[ActualizacionesImporte]  WITH CHECK ADD  CONSTRAINT [FK_ActualizacionesImporte_Clientes] FOREIGN KEY([id_cliente])
REFERENCES [dbo].[Clientes] ([id_cliente])
GO
ALTER TABLE [dbo].[ActualizacionesImporte] CHECK CONSTRAINT [FK_ActualizacionesImporte_Clientes]
GO
ALTER TABLE [dbo].[Articulos]  WITH CHECK ADD  CONSTRAINT [FK_Articulos_Rubros] FOREIGN KEY([id_rubro])
REFERENCES [dbo].[Rubros] ([id_rubro])
GO
ALTER TABLE [dbo].[Articulos] CHECK CONSTRAINT [FK_Articulos_Rubros]
GO
ALTER TABLE [dbo].[DetallesCatalogo]  WITH CHECK ADD  CONSTRAINT [FK_DetallesCatalogo_Articulos] FOREIGN KEY([id_articulo])
REFERENCES [dbo].[Articulos] ([id_articulo])
GO
ALTER TABLE [dbo].[DetallesCatalogo] CHECK CONSTRAINT [FK_DetallesCatalogo_Articulos]
GO
ALTER TABLE [dbo].[DetallesCatalogo]  WITH CHECK ADD  CONSTRAINT [FK_DetallesCatalogo_Catalogos] FOREIGN KEY([id_catalogo])
REFERENCES [dbo].[Catalogos] ([id_catalogo])
GO
ALTER TABLE [dbo].[DetallesCatalogo] CHECK CONSTRAINT [FK_DetallesCatalogo_Catalogos]
GO
ALTER TABLE [dbo].[DetallesVenta]  WITH CHECK ADD  CONSTRAINT [FK_DetallesVenta_DetallesVenta] FOREIGN KEY([id_articulo])
REFERENCES [dbo].[Articulos] ([id_articulo])
GO
ALTER TABLE [dbo].[DetallesVenta] CHECK CONSTRAINT [FK_DetallesVenta_DetallesVenta]
GO
ALTER TABLE [dbo].[DetallesVenta]  WITH CHECK ADD  CONSTRAINT [FK_DetallesVenta_Ventas] FOREIGN KEY([id_venta])
REFERENCES [dbo].[Ventas] ([id_venta])
GO
ALTER TABLE [dbo].[DetallesVenta] CHECK CONSTRAINT [FK_DetallesVenta_Ventas]
GO
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [FK_Pagos_Clientes] FOREIGN KEY([id_cliente])
REFERENCES [dbo].[Clientes] ([id_cliente])
GO
ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [FK_Pagos_Clientes]
GO
/****** Object:  StoredProcedure [dbo].[altaArticulo]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[altaArticulo](
		@articulo varchar(50), 
		@precio real,
		@stock varchar(50),
		@imagen varchar(50),
		@id_rubro int,
		@descripcion varchar(100)
		)
		AS
		BEGIN
			INSERT INTO Articulos (articulo, precio, stock, imagen, id_rubro, descripcion)
			VALUES(@articulo,@precio,@stock,@imagen,@id_rubro,@descripcion)
		END 
GO
/****** Object:  StoredProcedure [dbo].[altaCatalogo]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	--TRANSACCION alta catalogo
	CREATE PROCEDURE [dbo].[altaCatalogo](
		@ListArticulos VARCHAR(MAX),
		@fechaInicial DATE,
		@fechaFinal DATE,
		@descripcion VARCHAR(100)
	)
	AS
	BEGIN
		BEGIN TRANSACTION;
		SAVE TRANSACTION trxGenerarCatalogo;
			BEGIN TRY
				INSERT INTO Catalogos(fecha_inicio, fecha_fin, descripcion)
				VALUES (@fechaInicial, @fechaFinal,@descripcion)

				declare @idCatalogo int
				set @idCatalogo = @@IDENTITY

				SET NOCOUNT ON;

				IF LEN(@ListArticulos)>0
					BEGIN
						INSERT INTO DetallesCatalogo (id_articulo,id_catalogo) 
							SELECT id.id_articulo , @idCatalogo
							FROM (SELECT value 'id_articulo' FROM STRING_SPLIT(@ListArticulos, ';')) id 
					END
				ELSE    
					BEGIN 
						ROLLBACK TRANSACTION
					END

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
					ROLLBACK TRANSACTION;
			END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[altaCliente]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[altaCliente](
	@nombre varchar(50), 
	@apellido varchar(50),
	@numeroDoc int,
	@domicilio varchar(50),
	@telefono bigint,
	@saldo real
	)
	AS
	BEGIN
		INSERT INTO Clientes (nombre, apellido, domicilio, num_doc, telefono, saldo)
		VALUES(@nombre,@apellido,@domicilio,@numeroDoc,@telefono,@saldo)
	END 
GO
/****** Object:  StoredProcedure [dbo].[altaPago]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[altaPago](
		@montoPago real, 
		@fecha DATE,
		@idCliente int
		)
		AS
		BEGIN
			INSERT INTO Pagos (monto_pago, fecha, id_cliente)
			VALUES(@montoPago,@fecha,@idCliente)
		END 
GO
/****** Object:  StoredProcedure [dbo].[altaRubro]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[altaRubro](
		@rubro VARCHAR(50)
		) AS
		BEGIN
			INSERT INTO Rubros(rubro)
			VALUES (@rubro)
		END;
GO
/****** Object:  StoredProcedure [dbo].[altaSaldoInflacion]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[altaSaldoInflacion](
			@fecha DATE, 
			@porcentaje real,
			@idCliente int
			)
			AS
			BEGIN
				DECLARE @saldo real,
						@saldoInflacion real

				SELECT @saldo = c.saldo 
				FROM Clientes c
				WHERE c.id_cliente = @idCliente

				SELECT @saldoInflacion = @saldo*(1+@porcentaje)


				INSERT INTO ActualizacionesImporte (fecha, porcentaje,saldo,saldo_actualizado,id_cliente)
				VALUES(@fecha,@porcentaje,@saldo,@saldoInflacion,@idCliente)
			END 
GO
/****** Object:  StoredProcedure [dbo].[altaVenta]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[altaVenta](
		@ListValores VARCHAR(MAX),
		@fecha DATE,
		@id_cliente int
	)
	AS
	BEGIN
		BEGIN TRANSACTION;
		SAVE TRANSACTION trxGenerarVenta;
			BEGIN TRY
				INSERT INTO Ventas (fecha, id_cliente)
				VALUES (@fecha, @id_cliente)

				DECLARE @id_venta int;
				SELECT @id_venta = MAX(id_venta)
				FROM Ventas

				SET NOCOUNT ON;

				IF LEN(@ListValores)>0
					BEGIN
						INSERT INTO DetallesVenta(id_articulo, cantidad,precio_unitario,id_venta) 
							SELECT aux.id 'idArticulo', aux.cant 'cant', a.precio 'precioUni', @id_venta 'idVenta'
							FROM (SELECT SUBSTRING(val.valor,0,CHARINDEX(',',val.valor)) 'id', SUBSTRING(val.valor,CHARINDEX(',',val.valor)+1,3) 'cant'
								FROM (SELECT value 'valor' FROM STRING_SPLIT(@ListValores, ';')) val ) aux JOIN Articulos a ON a.id_articulo=aux.id
					END
				ELSE    
					BEGIN 
						ROLLBACK TRANSACTION
					END

				DECLARE @montoTotal real;

				SELECT @montoTotal = (SUM(dv.precio_unitario*dv.cantidad))
				FROM  DetallesVenta dv
				WHERE dv.id_venta = @id_venta

				UPDATE Ventas SET monto_total = @montoTotal
				WHERE id_venta = @id_venta

				UPDATE Clientes SET saldo = saldo + @montoTotal
				WHERE  id_cliente = @id_cliente

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION;
				END 
			END CATCH
		END
GO
/****** Object:  StoredProcedure [dbo].[bajaArticulo]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[bajaArticulo](
		@id int
		)
		AS
		BEGIN
			DELETE FROM Articulos WHERE id_articulo = @id
		END
GO
/****** Object:  StoredProcedure [dbo].[bajaCliente]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[bajaCliente](
	@id int
	)
	AS
	BEGIN
		DELETE FROM Clientes WHERE id_cliente = @id
	END
GO
/****** Object:  StoredProcedure [dbo].[bajaRubros]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[bajaRubros](
		@id int
		)
		AS
		BEGIN
			DELETE FROM Rubros WHERE id_rubro = @id
		END
GO
/****** Object:  StoredProcedure [dbo].[modificarArticulo]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[modificarArticulo](
		@articulo varchar(50), 
		@precio real,
		@stock varchar(50),
		@imagen varchar(50),
		@id_rubro int,
		@descripcion varchar(100),
		@id int
		)
		AS
		BEGIN
			UPDATE Articulos 
			SET articulo = @articulo, precio = @precio, stock = @stock, imagen = @imagen, id_rubro = @id_rubro, descripcion = @descripcion
			WHERE id_articulo = @id
		END 
GO
/****** Object:  StoredProcedure [dbo].[modificarCliente]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[modificarCliente](
		@nombre varchar(50), 
		@apellido varchar(50),
		@numeroDoc int,
		@domicilio varchar(50),
		@telefono bigint,
		@saldo real,
		@id int
		)
		AS
		BEGIN
			UPDATE Clientes SET nombre = @nombre, apellido = @apellido, num_doc = @numeroDoc, domicilio = @domicilio, telefono = @telefono, saldo = @saldo 
			WHERE id_cliente = @id
		END
GO
/****** Object:  StoredProcedure [dbo].[modificarRubro]    Script Date: 10/11/2019 21:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[modificarRubro](
		@rubro VARCHAR(50),
		@idRubro int
		) AS
		BEGIN
			UPDATE Rubros
			SET rubro = @rubro
			WHERE id_rubro = @idRubro
		END
GO
