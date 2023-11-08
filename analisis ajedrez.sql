-- MOSTRAR TODOS LOS DATOS DE LAS TRES TABLAS
select * from dbo.apertura a join dbo.jugadores j on a.id=j.id join dbo.partidas p on p.id=j.id


-- NUMERO DE PARTIDAS
select count(id) 'NUMERO DE PARTIDAS' from dbo.partidas


-- JUGADORES CON M�S CANTIDAD DE PARTIDAS, DE MAYOR A MENOR
with CANTIDAD as (
	select id, white_id 'jugador' from dbo.jugadores
	union all
	select id, black_id 'jugador' from dbo.jugadores
)
select distinct ca.jugador 'JUGADOR', count(p.id) 'CANTIDAD DE PARTIDAS QUE HA JUGADO'
from cantidad ca join dbo.partidas p on p.id=ca.id
group by ca.jugador order by 2 desc


-- METODOS DE VICTORIA M�S COMUNES, ORDENADOS POR PORCENTAJE. NO TOMAMOS EN CUENTA LAS TABLAS (draw)
select 
rank() over (order by count(id) desc) 'PUESTO',
case 
	when victory_status='outoftime' then 'VICTORIA POR TIEMPO'
	when victory_status='resign' then 'VICTORIA POR ABANDONO'
	when victory_status='mate' then 'VICTORIA POR JAQUE MATE'
	end 'TIPO DE VICTORIA', 
count(id) 'NUMERO DE OCURRENCIAS',
cast(100.0*count(id) / sum(count(*)) over() as decimal(4,2)) 'PORCENTAJE'
from dbo.partidas where victory_status<>'draw'
group by victory_status


-- LAS CIEN APERTURAS M�S COMUNES... POR ECO. TIENE EL PROBLEMA QUE MUCHAS APERTURAS COMPARTEN ECO
select top(100) opening_eco 'ECO',  count(id) 'CANTIDAD DE PARTIDAS'
from dbo.apertura
group by opening_eco
order by 2 desc


-- LAS CIEN APERTURAS M�S COMUNES... POR NOMBRE
select top(100) opening_name 'NOMBRE DE LA APERTURA',  count(id) 'CANTIDAD DE PARTIDAS'
from dbo.apertura
group by opening_name
order by 2 desc

-- SIGUE SIENDO SORPRENDENTE EL RESULTADO, QUE MUESTRA QUE LA APERTURA M�S UTILIZADA ES VAN'T KRUJIS, Y LA TERCERA
-- ES UNA VARIACI�N UN TANTO DUDOSA DE LA DEFENSA SICILIANA, EL ATAQUE BOWDLER


-- MOVIMIENTO QUE HACE JAQUE MATE, POR ORDEN DE M�S A MENOS COM�N
with ultimos as(
	select id, ltrim(right(moves, patindex('% %', reverse(moves)))) movis
	from dbo.apertura
)
select movis, count(id)
from ultimos
where substring(reverse(movis),1,1)='#'
group by movis
order by 2 desc

-- PODEMOS VER QUE, COMO SE ESPERABA, LO M�S PROBABLE ES HACER JAQUE MATE CON LA REINA/DAMA, Y MENOS PROBABLE, CON EL PE�N
-- LO MENOS PROBABLE, PORQUE NI SE ENCUENTRA EN LOS DATOS, ES JAQUE MATE POR ENROQUE, NO HAY NI ENROQUE CORTO NI LARGO
-- CUYA NOTACI�N ES, EN ORDEN, O-O Y O-O-O


-- MEDIA DE ELO POR DETERMINADAS APERTURAS, CONOCIMIENTO DE LAS APERTURAS
with elo_jugador as (
	select id, white_rating 'elo' from dbo.jugadores
	union all
	select id, black_rating 'elo' from dbo.jugadores
)
select a.opening_name 'APERTURA', avg(e.elo) 'MEDIA DE ELO' , avg(a.opening_ply) 'MEDIA DE MOVIMIENTOS TE�RICOS REALIZADOS'
from elo_jugador e join dbo.apertura a on a.id=e.id
where a.opening_name='Vienna Game' or a.opening_name='Ware Opening' or a.opening_name like '%hyper%ptero%'
or a.opening_name like 'Gruenfeld Defense'
group by a.opening_name
order by 2

-- PODEMOS VER, CON ESTA PEQUE�A MUESTRA, QUE APERTURAS M�S DUDOSAS (COMO LA WARE) AL SER NORMALMENTE JUGADAS POR PRINCIPIANTES
-- EL ELO MEDIO ES MENOR; EN OTRAS, COMO LA VIENA, AL SER JUGADA POR TODOS LOS RANGOS, ES UN ELO MEDIO; Y OTRAS,
-- COMO EL PTEROD�CTILO HIPERACELERADO Y LA GR�NFELD, AL SER MUY COMPLEJAS Y TE�RICAS, EL ELO ES MUY ELEVADO
-- LA INCLUSI�N DE LA MEDIA DE MOVIMIENTOS TE�RICOS REALIZADOS MUESTRA TAMBI�N LA DIFERENCIA DE CONOCIMIENTO ENTRE JUGADORES


-- BENEFICIAN LAS PARTIDAS LARGAS A BLANCAS O A NEGRAS?
select case 
	when winner='black' then 'NEGRAS'
	when winner='white' then 'BLANCAS'
	end 'GANADOR', avg(turns) 'MEDIA DE TURNOS' from dbo.partidas where winner <> 'draw'
group by winner
order by 2 desc

-- PODEMOS DECIR QUE BENEFICIA LIGERAMENTE A NEGRAS, AUNQUE LA DIFERENCIA ES TAN PEQUE�A QUE NO
-- DEBERIA SER CONSIDERADA


-- CANTIDAD DE PARTIDAS EVALUADAS POR CONTROL DE TIEMPO
select increment_code 'CONTROL DE TIEMPO', sum(cast(rated as int)) 'CANTIDAD DE PARTIDAS EVALUADAS'
from dbo.partidas
group by increment_code order by 1 
