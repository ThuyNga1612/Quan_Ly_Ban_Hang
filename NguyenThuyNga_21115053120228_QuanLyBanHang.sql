drop database if exists BanHang_NguyenThuyNga
--1. Tạo Database
create database BanHang_NguyenThuyNga
go
use BanHang_NguyenThuyNga
--Tạo bảng Phường_Xã, Quận_Huyện, Tỉnh_Thành Phố
create  table Tinh_TP(
	idTTP char(7) primary key,
	tenTTP nvarchar(50),
)
create table Quan_Huyen(
	idQH char(7) primary key,
	tenQH nvarchar(50),
	idTTP char(7) foreign key references Tinh_TP(idTTP)
		on delete cascade
		on update cascade,
)
create table Phuong_Xa(
	idPX char(7) primary key,
	tenPX nvarchar(50),
	idQH char(7) foreign key references Quan_Huyen(idQH)
		on delete cascade
		on update cascade,
)

--2.1 Tạo bảng KhachHang, NhaCungCap, NhanVien, SanPham
create table KhachHang(
	maKH char(7) primary key,
	tenKH nvarchar(50),
	diaChiKH nvarchar(50),
	SDT varchar(11),
	Email varchar(50),
	soDuTaiKhoan money,
	idPX char(7) foreign key references Phuong_Xa(idPX)
		on delete cascade
		on update cascade,
)
create table NhaCungCap(
	maNCC char(7) primary key,
	tenNCC nvarchar(50),
	diaChiNCC nvarchar(50),
	SDT varchar(11),
	nhanVienLienHe nvarchar(50),
)
create table NhanVien(
	maNV char(7) primary key,
	tenNV nvarchar(50),
	SDT varchar(11),
	Email varchar(50),
	gioiTinh char(1),
	DoB datetime,
	Salary money,
)
create table SanPham(
	maSP char(7) primary key,
	tenSP nvarchar(100),
	donGiaBan money,
	soLuongHienCon bigint,
	soLuongCanDuoi smallint,
)

--2.2 Tạo bảng PhieuNhap, DonDatHang_HoaDon
create table PhieuNhap(
	maPN char(7) primary key,
	ngayNhapHang date,
	maNCC char(7) foreign key references NhaCungCap(maNCC)
	ON DELETE cascade
	ON UPDATE cascade,
)
create table DonDatHang_HoaDon(
	maDH char(7) primary key,
	ngayTaoDH date,
	diaChiGiaoHang nvarchar(100),
	SDTGiaoHang varchar(11),
	maHoaDonDienTu char(13),
	ngayThanhToan date,
	ngayGiaoHang date,
		constraint CK_DonDatHang_HoaDon_ngayGiaoHang
			Check(ngayGiaoHang>=ngayThanhToan),
	trangThaiGiaoHang nvarchar(20),
		constraint CK_DonDatHang_HoaDon_trangThaiGiaoHang
			Check(trangThaiGiaoHang in(N'Chờ xử lý', N'Đang đóng gói', N'Đang vận chuyển', N'Đang giao hàng', N'Đã giao hàng')),
	maKH char(7) foreign key references KhachHang(maKH)
	ON DELETE cascade
	ON UPDATE cascade,
	maNV char(7) foreign key references NhanVien(maNV)
	ON DELETE cascade
	ON UPDATE cascade,
)

--2.3 Tạo bảng ChiTietPhieuNhap, ChiTietDonHang
create table ChiTietPhieuNhap(
	maPN char(7) foreign key references PhieuNhap(maPN)
	ON DELETE cascade
	ON UPDATE cascade,
	maSP char(7) foreign key references SanPham(maSP)
	ON DELETE cascade
	ON UPDATE cascade,
	primary key(maPN,maSP),
	soLuongNhap int
		constraint CK_ChiTietPhieuNhap_soLuongNhap
			check(soLuongNhap>=0),
	giaNhap money,
)
create table ChiTietDonHang(
	maDH char(7) foreign key references DonDatHang_HoaDon(maDH)
	ON DELETE cascade
	ON UPDATE cascade,
	maSP char(7) foreign key references SanPham(maSP)
	ON DELETE cascade
	ON UPDATE cascade,
	primary key(maDH,maSP),
	soLuongDat int
		constraint CK_ChiTietDonHang_soLuongDat
			Check(soLuongDat>=0),
	donGia money,
)

--a. KhachHang.Email và NhanVien.EMail có giá trị duy nhất và phải có chứa @
alter table KhachHang
	add constraint UQ_KhachHang_Email 
		unique(Email),
	constraint CK_KhachHang_Email
		check(Email like '%@%')
alter table NhanVien
	add constraint UQ_NhanVien_Email
		unique(Email),
	constraint CK_NhanVien_Email
		check(Email like '%@%')
--b. KhachHang.SoDuTaiKhoan phải đảm bảo không âm
alter table KhachHang
	add constraint CK_KhachHang_soDuTaiKhoan
		check(soDuTaiKhoan>=0)
--c. NhanVIen.Salary mặc định là 5.000.000 và ít nhất là 5.000.000
alter table NhanVien
	add constraint DF_NhanVien_Salary
		default 5000000 for Salary,
	constraint CK_NhanVien_Salary
		check(Salary>=5000000)
--d. NhanVien.GioiTInh mặc định là 'A' (Nam) và chỉ nhận một trong 3 giá trị ('A', 'U', 'L')
alter table NhanVien
	add constraint DF_NhanVien_gioiTinh
		default 'A' for gioiTinh,
	constraint CK_NhanVien_gioiTinh
		check(gioiTinh in('A','U','L'))
--e. NhanVien.DoB phải đảm bảo đủ 18 tuổi cho đến ngày hiện tại
alter table NhanVien
	add constraint CK_NhanVien_DoB
		check(DateDiff(year,'0:0',getDate()-DoB)>=18)
--f. SanPham.SoLuongHienCon phải đảm bảo không âm
	--g. SanPham.SoLuongCanDuoi mặc định là 5
alter table SanPham
	add constraint CK_SanPham_soLuongHienCon
		check(soLuongHienCon>=0),
	constraint DF_SanPham_soLuongCanDuoi
		default 5 for soLuongCanDuoi

--Nhập DL
set dateformat dmy
insert into Tinh_TP
values
	('47TTP01', N'Đà Nẵng'),
	('47TTP02', N'Hồ Chí Minh'),
	('47TTP03', N'Thừa Thiên Huế'),
	('47TTP04', N'Quảng Nam');
insert into Quan_Huyen
values
	('47QH001', N'Thanh Khê', '47TTP01'),
	('47QH002', N'Hải Châu', '47TTP01'),
	('47QH003', N'Điện Bàn', '47TTP04'),
	('47QH004', N'Quận 1', '47TTP02'),
	('47QH005', N'Tam Kỳ', '47TTP04');
insert into Phuong_Xa
values 
	('47PX001', N'Hòa Khê', '47QH001'),
	('47PX002', N'Thạc Gián', '47QH001'),
	('47PX003', N'Phước Ninh', '47QH002'),
	('47PX004', N'Thạch Thang', '47QH002'),
	('47PX005', N'Thuận Phước', '47QH002'),
	('47PX006', N'Vĩnh Điện', '47QH003'),
	('47PX007', N'Bến Nghé', '47QH004'),
	('47PX008', N'An Mỹ', '47QH005');
insert into KhachHang(maKH,tenKH,diaChiKH,SDT,Email,soDuTaiKhoan,idPX)
values
	('47KH001',N'Trần Hoàng Vy',N'137 Hà Huy Tập','0905753159','HoangVy@gmail.com',7000000,'47PX001'),
	('47KH002',N'Nguyễn Hoàng Mai Anh',N'169 Phan Thanh','01213645789','MaiAnhNguyenn@gmail.com',10000000,'47PX002'),
	('47KH003',N'Hàn Nhật Long',N'125 Phan Châu Trinh','0154789652','LongHanNhat123@gmail.com',60000000,'47PX003'),
	('47KH004',N'Bùi Trần Hoài An',N'166 Ông Ích Khiêm','0999521254','HoaiAnBui19@gmail.com',8000000,'47PX004'),
	('47KH005',N'Phạm Hoàng Minh Quân',N'20 Như Nguyệt','0901235468','PhmQuan12345@gmail.com',10000000,'47PX005'),
	('47KH006',N'Phạm Thiên Ân',N'68 Phạm Phú Thứ','0121568473','phuthu0203@gmail.com',9852000,'47PX006'),
	('47KH007',N'Nguyễn Đỗ Trọng Khôi',N'40 Nguyễn Huệ','0779123478','Nguyendotrongkhoi@gmail.com',15000000,'47PX007'),
	('47KH008',N'Trẫn Hữu Tiến Đạt',N'126 Lê Lợi','0905145896','tranhuutiendat@gmail.com',25000000,'47PX008');
insert into NhaCungCap(maNCC,tenNCC,diaChiNCC,SDT,nhanVienLienHe)
values
	('47NCC01',N'Nhà phân phối bia nước ngọt',N'2 QL1A, Bình Hưng Hòa, Bình Tân','02837508185',N'Nguyễn Phong Quốc Thiên'),
	('47NCC02',N'Nhà phân phối bánh kẹo Nguyễn Phước',N'12/36 Nguyễn Bặc, Phường 3, Tân Bình','0855154444',N'Dương Khải Huyền'),
	('47NCC03',N'Đại lý sữa Đức Huy',N'78A3 Cao Văn Lầu, Phường 2, Quận 6','0902555997',N'Trần Lê Bảo Quân'),
	('47NCC04',N'Nhà phân phối văn phòng phẩm Hoàng Hà',N'247/13 Độc Lập, Phường Tân Quý, Quận Tân Phú','0919542541',N'Phạm Đình Ân'),
	('47NCC05',N'Công ty phân phối hàng tiêu dùng Phú Hương',N'20 Núi Thành, Phường 13, Tân Bình','0903680919', N'Nguyễn Hữu Gia Thịnh');
insert into NhanVien(maNV,tenNV,SDT,Email,gioiTinh,DoB,Salary)
values 
	('47NV001',N'Hoàng Tú Anh','0935012003','Anhtuhoang89@gmail.com','A','11/11/1999',5500000),
	('47NV002',N'Phan Thế Bảo','0909125136','Baophann0809@gmail.com','A','26/11/1998',7800000),
	('47NV003',N'Nguyễn Vũ Hoàng Bách','0121123124','VuHoangBach@gmail.com','U','22/10/1996',7600000),
	('47NV004',N'Trần Đức Trí','0236256451','tranductri09@gmail.com','A','1/5/1992',9000000),
	('47NV005',N'Trần Đỗ Kim Ánh','0123568489','Anhtrankim@gmail.com','A','12/8/1990',6000000);
insert into SanPham(maSP,tenSP,donGiaBan,soLuongHienCon,soLuongCanDuoi)
values
	('47SP001',N'Vinamilk Thùng 48 Hộp Sữa Tươi Tiệt Trùng 100% Ít Đường - 110Ml',235000,15,5),
	('47SP002',N'Thùng 30 gói mì Lẩu Thái tôm 80g',214000,50,6),
	('47SP003',N'Thùng 12 chai nước ngọt Mirinda xá xị 1.5 lít',192000,35,3),
	('47SP004',N'Hộp 20 cây bút bi Thiên Long',70000,15,3),
	('47SP005',N'Thùng giấy IK Plus A4 70gsm',312000,100,3),
	('47SP006',N'Hủ kẹo trái cây thập cẩm của Đức 966g',220000,30,5),
	('47SP007',N'Kẹo viên bạc hà Yumearth 93.6g',98000,100,5),
	('47SP008',N'Thùng 12 hộp sữa đậu đen Sahmyook óc chó hạnh nhân 950ml',950000,10,2),
	('47SP009',N'Sữa bột cho bé Enfamil A+ số 2 lon 1.7kg',935000,20,5),
	('47SP010',N'Rượu Vang La Fiole du Pape Pere Anselme Chateauneuf-du-Pape',1700000,8,2),
	('47SP011',N'Sò điệp hàng đông lạnh Oceangift 240g',235000,30,5);
insert into PhieuNhap(maPN,ngayNhapHang,maNCC)
values
	('47PN001','14/8/2022','47NCC01'),
	('47PN002','15/8/2022','47NCC02'),
	('47PN003','17/8/2022','47NCC03'),
	('47PN004','14/8/2022','47NCC04'),
	('47PN005','16/8/2022','47NCC05'),
	('47PN006','1/10/2022','47NCC04'),
	('47PN007','1/10/2022','47NCC03'),
	('47PN008','2/10/2022','47NCC01'),
	('47PN009','4/10/2022','47NCC02'),
	('47PN010','5/10/2022','47NCC05'),
	('47PN011','5/10/2022','47NCC04'),
	('47PN012','7/10/2022','47NCC01'),
	('47PN013','10/10/2022','47NCC03'),
	('47PN014','10/10/2022','47NCC03'),
	('47PN015','11/10/2022','47NCC01');
insert into DonDatHang_HoaDon(maDH,ngayTaoDH,diaChiGiaoHang,SDTGiaoHang,maHoaDonDienTu,ngayThanhToan,ngayGiaoHang,trangThaiGiaoHang,maKH,maNV)
values
	('47DH001','14/10/2021',N'137 Hà Huy Tập, Hòa Khê, Thanh Khê, Đà Nẵng','0123456789','123ABC123ABC1','14/10/2021','15/10/2021',N'Đã giao hàng','47KH001','47NV001'),
	('47DH002','15/10/2021',N'169 Phan Thanh, Thạc Gián, Thanh Khê, Đà Nẵng','0905126456','PMWQ12345HFD2','15/10/2021','18/10/2021',N'Đã giao hàng','47KH002','47NV002'),
	('47DH003','16/10/2022',N'125 Phan Châu Trinh,Phước Ninh,Hải Châu,Đà Nẵng','0901245869','PMQ1234ABC123','20/10/2022','25/10/2022',N'Đang giao hàng','47KH003','47NV003'),
	('47DH004','1/11/2022',N'40 Nguyễn Huệ, Bến Nghé, Quận 1, Hồ Chí Minh','0989123456','567NGH898177','1/11/2022','4/11/2022',N'Đang giao hàng','47KH007','47NV004'),
	('47DH005','2/11/2022',N'68 Phạm Thú Thứ,Vĩnh Điện, Điện Bàn,Quảng Nam','0902123789','NBH678BBB999','2/11/2022','5/11/2022',N'Đang giao hàng','47KH006','47NV005'),
	('47DH006','3/11/2022',N'137 Hà Huy Tập, Hòa Khê, Thanh Khê, Đà Nẵng','0123456789','123ABC543ABC1','8/11/2022','8/11/2022',N'Đã giao hàng','47KH001','47NV004'),
	('47DH007','5/11/2022',N'137 Hà Huy Tập, Hòa Khê, Thanh Khê, Đà Nẵng','0123456789','783ABC123ABC1','8/11/2022','8/11/2022',N'Đã giao hàng','47KH001','47NV002'),
	('47DH008','5/11/2022',N'40 Nguyễn Huệ, Bến Nghé, Quận 1, Hồ Chí Minh','0123258456','993ABC123ABC1','14/11/2022','14/11/2022',N'Đang giao hàng','47KH007','47NV001');
insert into ChiTietPhieuNhap(maPN,maSP,soLuongNhap,giaNhap) 
values 
	('47PN001','47SP003',100,120000),
	('47PN002','47SP006',70,150000),
	('47PN003','47SP001',50,150000),
	('47PN004','47SP004',100,40000),
	('47PN005','47SP002',60,170000),
	('47PN006','47SP005',40,180000),
	('47PN007','47SP001',40,160000),
	('47PN008','47SP003',40,145000),
	('47PN009','47SP006',60,170000),
	('47PN010','47SP002',50,200000),
	('47PN011','47SP005',40,180000),
	('47PN012','47SP003',50,150000),
	('47PN013','47SP001',50,155000),
	('47PN014','47SP001',70,160000),
	('47PN015','47SP003',70,130000);
insert into ChiTietDonHang(maSP,maDH,soLuongDat,donGia)
values
	('47SP002','47DH004',5,200000),
	('47SP001','47DH001',3,235000),
	('47SP001','47DH003',3,235000),
	('47SP002','47DH002',5,214000),
	('47SP003','47DH003',2,192000),
	('47SP004','47DH004',5,70000),
	('47SP001','47DH002',4,200000),
	('47SP003','47DH002',1,180000),
	('47SP005','47DH005',2,310000),
	('47SP010','47DH005',3,1500000);

--Truy Vấn DL
	--a. thống kê những sản phẩm thuộc top 3 bán chạy nhất  
select s.maSP, s.tenSP, sum(soLuongDat) as TSLB
from SanPham as s, ChiTietDonHang as c
where s.maSP=c.maSP
group by s.maSP, s.tenSP
having sum(soLuongDat) in (select distinct top 3 sum(soLuongDat)
							from ChiTietDonHang
							group by maSP
							order by sum(soLuongDat) desc )
order by TSLB desc

	--b. thống kê những sản phẩm chưa bán được cái nào  
select *
from SanPham
where maSP not in ( select distinct maSP
					from ChiTietDonHang)

	--c. hiển thị những đơn hàng giao thành công và thông tin cụ thể của người giao hàng (position) 
select hd.maDH, hd.trangThaiGiaoHang, nv.*
from DonDatHang_HoaDon as hd, NhanVien as nv
where hd.maNV=nv.maNV and trangThaiGiaoHang=N'Đã giao hàng' 

	--d. hiển thị những đơn hàng của khách hàng ở Đà Nẵng hoặc Quảng Nam 
	--(nên có điều kiện DN và QN, mặc định là DN hoặc QN) 
select distinct hd.maKH, hd.maDH, hd.diaChiGiaoHang
from KhachHang as kh, Tinh_TP as tp, Quan_Huyen as qh, Phuong_Xa as px, DonDatHang_HoaDon as hd
where hd.maKH=kh.maKH and kh.idPX=px.idPX and px.idQH=qh.idQH and qh.idTTP=tp.idTTP
	and (tp.idTTP='47TTP01' or tp.idTTP='47TTP04')
group by hd.maKH, hd.maDH, hd.diaChiGiaoHang

	--e. hiển thị những sản phẩm có giá từ 500k – 2.000k 
select *
from SanPham
where donGiaBan between 500000 and 2000000

	--f. những tháng có doanh thu trên 2000000 (có tham số là định mức tiền)  
select sum(CTDH.donGia*CTDH.soLuongDat) as DoanhThu, month(HD.ngayThanhToan) as Thang,year(HD.ngayThanhToan) as Nam
from ChiTietDonHang as CTDH,DonDatHang_HoaDon as HD
where CTDH.maDH=HD.maDH
group by year(HD.ngayThanhToan), month(HD.ngayThanhToan) 
having  sum(CTDH.donGia*CTDH.soLuongDat)>2000000

	--g. thống kê số lượng khách theo từng tỉnh/thành phố (sắp xếp giảm dần)  
select tp.tenTTP, count(tp.idTTP) as 'Số lượng khách'
from KhachHang as kh, Phuong_Xa as px, Quan_Huyen as qh, Tinh_TP as tp
where kh.idPX=px.idPX and px.idQH=qh.idQH and qh.idTTP=tp.idTTP
group by tp.tenTTP, tp.idTTP
order by count(tp.idTTP) desc

	--h. thống kê giá trung bình, giá max, giá min nhập hàng cho mỗi sản phẩm  
select ct.maSP, sp.tensp, max(giaNhap) as 'Max', min(giaNhap) as 'Min', avg(giaNhap) as 'TB'
from ChiTietPhieuNhap as ct, SanPham as sp
where ct.maSP=sp.maSP
group by ct.maSP, sp.tenSP

	--i. hiển thị giá trung bình, giá max, giá min bán ra cho mỗi sản phẩm
select sp.maSP, sp.tenSP, max(donGia) as 'Max', min(donGia) as 'Min', avg(distinct donGia) as 'TB'
from ChiTietDonHang as ct, SanPham as sp
where ct.maSP=sp.maSP
group by sp.maSP, sp.tenSP

	--j. thống kê số lần khách hàng mua hàng của từng khách hàng (sắp xếp giảm dần) 
select kh.tenKH, count(hd.maKH) as'Số lần mua'
from DonDatHang_HoaDon as hd, KhachHang as kh
where hd.maKH=kh.maKH
group by kh.tenKH
order by count(hd.maKH) desc
	
	--k. hiển thị thông tin chi tiết của các sản phẩm mà có số lần nhập hàng nhiều nhất 
select sp.maSP, sp.tenSP, count(ct.maSP) as 'Số lần nhập'
from SanPham as sp, ChiTietPhieuNhap as ct
where sp.maSP=ct.maSP
group by ct.maSP, sp.maSP, sp.tenSP
having count(ct.maSP) in(select top 1 count(ct.maSP) as 'Số lần nhập'
						 from ChiTietPhieuNhap as ct
						 group by ct.maSP
			 			 order by count(ct.maSP) desc)
order by count(ct.maSP) desc

	--l. hiển thị thông tin chi tiết của các nhà cung cấp mà có số lần nhập hàng lớn hơn 3 
select ncc.maNCC, ncc.tenNCC, count(ct.maSP) as 'Số lần nhập'
from ChiTietPhieuNhap as ct, NhaCungCap as ncc, PhieuNhap as pn
where ct.maPN=pn.maPN and pn.maNCC=ncc.maNCC
group by ct.maSP, ncc.maNCC, ncc.tenNCC
having count(ct.maSP) >3

go
--Viết thủ tục để đếm số sản phẩm 1 nhà cung cấp nào đó đã nhập
	--Cách 1: Có tham số vào
create proc pr_DemSoSP
	@mancc char(7)
as
begin
	select n.maNCC, n.tenNCC, count(maSP) as 'Số sản phẩm'
	from NhaCungCap n
		join PhieuNhap as p
			on p.maNCC = n.maNCC
			join ChiTietPhieuNhap as c
				on c.maPN = p.maPN
	where n.maNCC = @mancc
	group by n.maNCC, n.tenNCC
end
go
--gọi thủ tục
exec pr_DemSoSP '47NCC01'
go

	--Cách 2: Có tham số ra
create proc pr_DemSoSP_ThamSoRa
	@mancc char(7),
	@soSP int output
as
begin
	select @soSP = count(maSP)
	from NhaCungCap n
		join PhieuNhap as p
			on p.maNCC = n.maNCC
			join ChiTietPhieuNhap as c 
				on c.maPN = p.maPN
	where n.maNCC = @mancc
	print @soSP
end
go
--gọi thủ tục
declare @mancc char (7)='47NCC01' , @soSP int 
exec pr_DemSoSP_ThamSoRa @mancc , @soSP output 
print N'Nhà Cung Cấp ' + @mancc +N' Sản phẩm cung cấp: ' + STR(@soSP) 

go

--Viết thủ tục để hiển thị thông tin những sản phẩm có số lượng đã nhập ít hơn 1 giá trị nào đó 
--và giá nhập lớn hơn 1 giá trị nào đó
create proc pr_TTSP_SL_GN
	@sl int,
	@gia money
as
begin
	select s.maSP, s.tenSP, sum(soLuongNhap) as 'SoLuongNhap', avg(giaNhap) as 'GiaNhap'
	from SanPham as s
		join ChiTietPhieuNhap as c
			on c.maSP = s.maSP
	group by s.maSP, s.tenSP
	having sum(soLuongNhap) < @sl and avg(giaNhap) > @gia
end
go
--gọi thủ tục
exec pr_TTSP_SL_GN 1000, 10000
		
go
--Viết thủ tục hiển thị thông tin của đơn hàng với tổng số lượng đặt hàng lớn hơn 1 giá trị nào đó
create proc pr_DH_TSLD
	@tsld int
as
begin
	select d.maDH, ngayGiaoHang, ngayTaoDH, sum(soLuongDat) as 'Tổng số lượng đặt'
	from DonDatHang_HoaDon d
		join ChiTietDonHang as c
			on d.maDH = c.maDH
	group by d.maDH, ngayGiaoHang, ngayTaoDH
	having sum(soLuongDat) > @tsld
end
go
--gọi thủ tục
exec pr_DH_TSLD 2
go

--1. Viết các đoạn lệnh để thực hiện các công việc sau:
	--a. Hãy xuất dạng Text giá tiền của những sản phẩm có giá tiền lớn nhất
begin
	declare @gia money
	declare @t_gia nvarchar(50)
	select top 1 with ties @gia = donGiaBan, @t_gia = tenSP
	from SanPham
	order by donGiaBan desc
	print N'Sản Phẩm có giá cao nhất: '+ @t_gia + ' ' + format(@gia,'##,#\ VNĐ', 'es-ES')
end

go
	--b.Hãy viết đoạn lệnh để tìm giá trị id tiếp theo của bảng sản phẩm, 
	--và chèn dữ liệu vào bảng sản phẩm
--Cách 1:
select concat('47SP', format(max(right(maSP, 3))+1, 'D3'))
from SanPham
go

--Cách 2: Viết đoạn lệnh
declare @idmax char(7),
		@idnext char(7)
select @idmax = maSP
from SanPham
set @idmax= right(@idmax, 3)
set @idnext= concat('47SP', format(@idmax+1, 'D3'))
print @idnext
go

	--c.Hãy viết đoạn lệnh để đếm số lần mua hàng của từng khách hàng, nếu số lần mua lớn hơn 
	--hoặc bằng 10 thì ghi ‘Khách hàng thân thiết’, ngược lại ghi ‘Khách hàng tiềm năng’
begin
	select hd.maKH, kh.tenKH, count(hd.maKH) as 'Số lần mua',
	case
		when count(hd.maKH)>=10 then N'Khách hàng thân thiết'
		else N'Khách hàng tiềm năng'
	end as N'Dạng KH'
	from DonDatHang_HoaDon as hd
		join KhachHang as kh
			on hd.maKH=kh.maKH
	group by  kh.tenKH, hd.maKH
end
go

	--d.Hãy viết đoạn lệnh để tính tiền cho đơn hàng mới nhất (đơn hàng vừa được mua).
		--i. Nếu tổng tiền lớn hơn 1.000.000 thì áp dụng giảm 10% và cập nhật lại tổng tiền mới cần trả;
		--ii.Nếu tổng tiền từ 400.000 đến dưới 1.000.000 thì tổng tiền không cần cộng phí ship;
		--iii. Nếu tổng tiền nhỏ hơn 400.000 thì tổng tiền gồm tổng tiền hàng và phí ship (giả sử phí ship là 40.000)
begin
	select Top 1 with ties ctdh.maDH, format(SUM(SoLuongDat*DonGia), '##,#\ VNĐ', 'es-ES') as N'Tổng tiền', CONVERT(varchar, NgayThanhToan, 103) as N'Ngày Thanh Toán',DateDiff(Day, NgayThanhToan, GETDATE()) as N'Cách Đây (ngày)',
		case 
			when sum(soLuongDat*donGia) > 1000000 then sum(soLuongDat*donGia)* 0.9
			when sum(soLuongDat*donGia) < 400000 then sum(soLuongDat*donGia) + 40000
			else format(SUM(SoLuongDat*DonGia), '##,#\ VNĐ', 'es-ES')
		end as N'Số tiền phải trả'
	from DonDatHang_HoaDon as hd
		 join ChiTietDonHang as ctdh
			on hd.maDH = ctdh.maDH
	where ngayThanhToan is not null
	group by ctdh.maDH, ngayThanhToan
	order by DateDiff(Day, NgayThanhToan, GETDATE()) asc
end

	--e.Hãy viết đoạn lệnh để thực hiện yêu cầu: kiểm tra xem có đơn hàng nào mà tồn tại số lượng 
	--mua lớn hơn số lượng hiện có -> nếu có thì cập nhật số lượng hiện còn của các sản phẩm nằm 
	--trong giỏ hàng mà có số lượng đặt lớn hơn số lượng hiện còn bằng cách gán về số lượng đặt là 0

go
/*update ChiTietDonHang
set soLuongDat=3
where maSP='47SP001'*/
go
begin
	select ctdh.maDH, sp.maSP, tenSP, soLuongDat, soLuongHienCon
	from ChiTietDonHang as ctdh
		join SanPham as sp
			on ctdh.maSP = sp.maSP
	update ChiTietDonHang
	set soLuongDat=0
	where maDH in ( select maDH
					from SanPham as sp
						left join ChiTietDonHang as ctdh
							on sp.maSP = ctdh.maSP
					where soLuongDat > soLuongHienCon)
	  and MaSP in ( select sp.maSP
					from SanPham as sp
						left JOIN ChiTietDonHang as ctdh
							on sp.maSP = ctdh.maSP
					where soLuongDat > soLuongHienCon)
end
go

	--f.Viết đoạn lệnh để tính khuyến mãi theo điều kiện sau: nếu đơn hàng trên 1 triệu thì được giảm 10%,
	--cứ tăng thêm 1 triệu nữa thì được giảm thêm 2% nữa.
begin
	select ctdh.maDH, format(SUM(SoLuongDat*DonGia), '##,#\ VNĐ', 'es-ES') as N'Tổng tiền',
	case	
		when sum(soLuongDat*donGia)>1000000 and sum(soLuongDat*donGia)<2000000 then format(0.1, '#\ %', 'vi-VN')
		when sum(soLuongDat*donGia)<1000000 then format(0, '0\ %', 'vi-VN')
		else FORMAT(0.1 + 0.02*FLOOR((SUM(SoLuongDat*DonGia)-1000000)/1000000), '#\ %', 'vi-VN')
	end as N'Khuyến mãi'
	from DonDatHang_HoaDon as hd
		 join ChiTietDonHang as ctdh
			on hd.maDH = ctdh.maDH
	group by ctdh.maDH
end
go

	--g.Viết đoạn lệnh để đếm số lần mua của mỗi khách hàng, nếu số lần mua trên 5 thì hiển thị “Khách Vip”,
	--ngược lại hiển thị “Khách tiềm năng”
begin
	select hd.maKH, kh.tenKH, count(hd.maKH) as 'Số lần mua',
	case
		when count(hd.maKH)>5 then N'Khách VIP'
		else N'Khách tiềm năng'
	end as N'Dạng KH'
	from DonDatHang_HoaDon as hd
		join KhachHang as kh
			on hd.maKH=kh.maKH
	group by  kh.tenKH, hd.maKH
end
go

--2. Viết các thủ tục
	--a.Tăng tự động các column ID cho tất cả các table được sinh từ thực thể mạnh
		--(viết cả hàm và thủ tục để thực hiện việc này)
	--Thủ tục

	--b.thống kê các sản phẩm bán chạy (có tham số)
create proc pr_TKSP_BanChay
	@so int
as
begin
	select s.maSP, s.tenSP, sum(soLuongDat) as 'Số lượng mua'
	from SanPham as s
		join ChiTietDonHang as c
			on s.maSP= c.maSP
	group by s.maSP, s.tenSP
	having sum(soLuongDat) in ( select distinct top (@so) sum(soLuongDat)
								from ChiTietDonHang 
								group by maSP
								order by sum(soLuongDat) desc )
	order by sum(soLuongDat) desc 
end
go
--Gọi thủ tục
exec pr_TKSP_BanChay 3
go

	--c.những tháng có doanh thu trên 200000 (có tham số là định mức tiền)
create proc pr_DoanhThu
	@dt money
as
begin
	select month(d.ngayThanhToan) as N'Tháng',year(d.ngayThanhToan) as N'Năm', sum(c.donGia*c.soLuongDat) as 'Doanh Thu'
	from ChiTietDonHang as c,DonDatHang_HoaDon as d
	where c.maDH=d.maDH
	group by month(d.ngayThanhToan) , year(d.ngayThanhToan)
	having  sum(c.donGia*c.soLuongDat)>@dt
end
go
--Gọi thủ tục
exec pr_DoanhThu 200000
go

	--d.thống kê số lượng khách nhau theo từng tỉnh/thành phố (sắp xếp giảm dần)
create proc pr_TKSLK_TheoTinh
as
begin
	select tp.tenTTP, count(tp.idTTP) as 'Số lượng khách'
	from KhachHang as kh, Phuong_Xa as px, Quan_Huyen as qh, Tinh_TP as tp
	where kh.idPX=px.idPX and px.idQH=qh.idQH and qh.idTTP=tp.idTTP
	group by tp.tenTTP, tp.idTTP
	order by count(tp.idTTP) desc
end
go

--Gọi thủ tục
exec pr_TKSLK_TheoTinh
go

	--e.thống kê giá trung bình, giá max, giá min ở các phiếu nhập hàng cho mỗi sản phẩm
create proc pr_TKG_PhieuNhap
as
begin
	select ct.maSP, sp.tensp, max(giaNhap) as 'Max', min(giaNhap) as 'Min', avg(giaNhap) as 'TB'
	from ChiTietPhieuNhap as ct, SanPham as sp
	where ct.maSP=sp.maSP
	group by ct.maSP, sp.tenSP
end
go
--Gọi thủ tục
exec pr_TKG_PhieuNhap
go

	--f.thống kê số lần khách hàng mua hàng (sắp xếp giảm dần)
create proc pr_TKSL_muahang
as
begin
	select kh.tenKH, count(hd.maKH) as'Số lần mua'
	from DonDatHang_HoaDon as hd, KhachHang as kh
	where hd.maKH=kh.maKH
	group by kh.tenKH
	order by count(hd.maKH) desc
end
go
--Gọi thủ tục
exec pr_TKSL_muahang
go

	--g.thông kê năm có doanh thu lớn nhất (cả thông tin về năm và thông tin về doanh thu) 
create proc pr_DoanhThu_Nam
	@nam as int output,
	@tg as money output
as
begin
	select @tg=sum(c.donGia*c.soLuongDat), @nam=year(h.ngayThanhToan)
	from ChiTietDonHang as c
			join DonDatHang_HoaDon as h
				on c.maDH=h.maDH 
	group by  year(h.ngayThanhToan)
	having sum(c.donGia*c.soLuongDat) in (	select distinct top 1 sum(c.donGia*c.soLuongDat)
											from ChiTietDonHang
											group by maSP
											order by sum(c.donGia*c.soLuongDat) desc)
	order by sum(c.donGia*c.soLuongDat) desc
end
go
--Gọi thủ tục
declare @nam int,@tg money
exec pr_DoanhThu_Nam @nam output,@tg output
print @nam 
print @tg
select @nam as N'Năm',@tg as N'Doanh Thu Lớn Nhất'
go

--3.Viết các hàm tính:
	--a.Thành tiền khi biết đơn giá và số lượng đặt
create function fn_ThanhTien
(
	@donGia money,
	@sld int
)
returns money
begin
	return @donGia * @sld
end
go
--Gọi thủ tục
select dbo.fn_ThanhTien(500000, 5)
go

	--b.tổng tiền cho mỗi đơn hàng khi biết mã đơn hàng
create function fn_TongTien
(
	@maDH char(7)
)
returns money
begin
	return(	select sum(c.soLuongDat*c.donGia)
			from ChiTietDonHang c
			where c.maDH=@maDH)
end
go 
--gọi thủ tục
select dbo.fn_TongTien('47DH004')
go

	--c.Tính thành tiền sau khi đã áp dụng khuyến mãi khi biết mã khuyến mãi,số lượng bán,đơn giá
create function fn_ThanhTien_KhuyenMai(
	@solg int,
	@gia money,
	@kmai dec(4,2)
)
returns money
begin
	return @solg * @gia *(1-@kmai)
end
go
--Gọi hàm 
select dbo.fn_ThanhTien_KhuyenMai(3,421000,0.2)
go

	--d.tổng tiền thu vào theo từng tháng – năm hoặc từ ngày đến ngày khi biết tháng 
	--và năm (hoặc ngày bắt đầu và ngày kết thúc)
create function fn_TongtienThu
(
	@ngaybd date,
	@ngaykt date
)
returns money
begin
	return (select sum(donGia*soLuongDat)
            from DonDatHang_HoaDon as hd
				JOIN ChiTietDonHang as ctdh
					ON hd.MaDH = ctdh.MaDH 
			where hd.NgayThanhToan between @ngaybd and @ngaykt)
end
go
--Gọi hàm
select *
from ChiTietDonHang
set dateformat dmy
select dbo.fn_TongtienThu('10/10/2021', '20/10/2021') as N'Doanh Thu'
go

--4.Viết các trigger để:
	--1.Khi insert – update – delete ở bảng ChiTietDonHang 
		--tăng/giảm số lượng ở bảng SanPham 
		--cập nhật đơn giá bán ở bảng ChiTietDonHang theo giá bán hiện tại (được lưu ở bảng SanPham)  
	--1.1.Khi insert ở bảng ChiTietDonHang 
	--Cách 1: 
alter table SanPham
	drop constraint CK_SanPham_soLuongHienCon
go
create trigger tg_ChiTietDonHang_Insert
on ChiTietDonHang
after insert
as
begin
	--autoFill giá trị đơn giá
	update ChiTietDonHang
	set donGia = s.donGiaBan
	from SanPham as s
		join inserted as i
			on s.maSP = i.maSP
	where ChiTietDonHang.maDH = i.maDH
		and ChiTietDonHang.maSP= i.maSP
	--cập nhật lại số lượng còn
	update SanPham
	set soLuongHienCon = soLuongHienCon - i.soLuongDat
	from inserted as i
	where SanPham.maSP= i.maSP
	
	if exists ( select *
				from SanPham
				where soLuongHienCon < 0)
		rollback
end
go
--
select *
from ChiTietDonHang
select *
from SanPham
go
insert into ChiTietDonHang(maDH, maSP, soLuongDat)
values
	('47DH005', '47SP001', 7);
select *
from ChiTietDonHang
select *
from SanPham
go
	--Cách 2: Kiểm tra trước rồi mới insert (giữ nguyên constraint)
alter table SanPham
	add constraint CK_SanPham_soLuongHienCon
		check(soLuongHienCon >=0)
go
create trigger tg_ChiTietDonHang_Insert_InsteadOf
on ChiTietDonHang
instead of insert
--ràng buộc vẫn giữ nguyên
--được kích hoạt trước khi insert
as
begin
	--kích hoạt trigger
	print N'Xem thử đã insert dữ liệu chưa!'
	select * from inserted
	--kiểm tra xem trong inserted và sản phẩm: soLuongDat < soLuongHienCon
	if exists (	select *
				from SanPham as s, inserted as i
				where s.maSP=i.maSP and s.soLuongHienCon < i.soLuongDat)
		print N'Mua vượt quá số lượng còn trong kho!'
	else
		insert into ChiTietDonHang (maDH, maSP, soLuongDat)
		values('47DH005', '47SP002', 20)
end
go
--
select * from ChiTietDonHang
select * from SanPham
go
	--1.2.Khi delete ở bảng ChiTietDonHang 
create trigger tg_ChiTietDonHang_Delete
on ChiTietDonHang
after delete
as
begin
	update ChiTietDonHang
	set maSP= d.maSP, maDH= d.maDH
	from deleted as d
		join ChiTietDonHang as c
			on d.maSP = c.maSP
			and d.maDH = c.maDH
	update SanPham
	set soLuongHienCon = soLuongHienCon + d.soLuongDat
	from deleted as d
	where SanPham.maSP = d.maSP
end

--
go
select *
from ChiTietDonHang
select *
from SanPham
delete ChiTietDonHang
where maDH= '47DH005' and maSP= '47SP001'
select *
from ChiTietDonHang
select *
from SanPham
go

	--1.3. Khi update ở bảng ChiTietDonHang
create trigger tg_ChiTietDonHang_Update
on ChiTietDonHang
after update
as
begin
	update SanPham
	set SoLuongHienCon = SoLuongHienCon - (t.SoLuongDat - d.SoLuongDat)
	from SanPham as sp
		join inserted as t
			ON sp.MaSP = t.MaSP
				join deleted as d
					ON sp.MaSP = d.MaSP

end
go
--
select *
from ChiTietDonHang
select *
from SanPham
update ChiTietDonHang
set soLuongDat = 5
where maDH= '47DH004' and maSP= '47SP001'
select *
from ChiTietDonHang
select *
from SanPham
go

	--2.Khi insert – update – delete ở bảng ChiTietPhieuNhap 
		--tăng/giảm số lượng ở bảng SanPham  
		--cập nhật đơn giá bán ở bảng SanPham (lãi 30%) 
	--2.1.Khi insert ở bảng ChiTietPhieuNhap
create trigger tg_ChiTietPhieuNhap_Insert
on ChiTietPhieuNhap
after insert
as
begin
	update SanPham
	set soLuongHienCon = soLuongHienCon + i.soLuongNhap,
		donGiaBan = i.giaNhap*1.3
	from inserted as i
	where SanPham.maSP = i.maSP
end
--
go
select *
from ChiTietPhieuNhap
select *
from SanPham
insert into ChiTietPhieuNhap
values
	('47PN001', '47SP002', 100, 170000);
select *
from ChiTietPhieuNhap
select *
from SanPham
go

	--2.2.Khi delete ở bảng ChiTietPhieuNhap
create trigger tg_ChiTietPhieuNhap_Delete
on ChiTietPhieuNhap
after delete
as
begin
	update SanPham
	set soLuongHienCon= soLuongHienCon - d.soLuongNhap
	from deleted as d
	where SanPham.maSP = d.maSP
end
--
go
select *
from ChiTietPhieuNhap
select *
from SanPham
delete ChiTietPhieuNhap
where maPN ='47PN001' and maSP= '47SP002'
select *
from ChiTietPhieuNhap
select *
from SanPham
go

	--2.3.Khi update ở bảng ChiTietPhieuNhap
create trigger tg_ChiTietPhieuNhap_Update
on ChiTietPhieuNhap
after update
as
begin
	update SanPham
	set soLuongHienCon = soLuongHienCon +(i.soLuongNhap - d.soLuongNhap),
		donGiaBan = i.soLuongNhap*1.3
		from SanPham as sp
			join inserted as i
				on i.maSP = sp.maSP
					join deleted as d
						on d.maSP = sp.maSP
	
end
--
go
select *
from ChiTietPhieuNhap
select *
from SanPham
update ChiTietPhieuNhap
set soLuongNhap= 150 , giaNhap= 160000
where maPN ='47PN001' and maSP= '47SP003'
select *
from ChiTietPhieuNhap
select *
from SanPham