/// Filtro de la lista de movimientos (Reto 4).
///
/// Pertenece al estado de presentación, no al dominio: `WalletSummary` no sabe
/// qué está mirando el usuario. El saldo total se calcula siempre sobre todos
/// los movimientos, de modo que filtrar no altera los totales.
enum MovementFilter { all, income, expense }
