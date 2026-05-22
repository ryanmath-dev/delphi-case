/* =====================================================================
   Migration 001 - Add OBSERVACAO to PEDIDO
   ---------------------------------------------------------------------
   Aplica em bases existentes (criadas antes da Fase 7).
   Bases novas, criadas via db.sql atualizado, ja vem com a coluna.
   ===================================================================== */

SET SQL DIALECT 3;

ALTER TABLE PEDIDO ADD OBSERVACAO VARCHAR(255);

COMMIT;
