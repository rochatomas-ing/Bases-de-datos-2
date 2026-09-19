--Ejercicio 1.

ALTER TABLE instalacion
    ADD CONSTRAINT fk_zona_nroc FOREIGN KEY (zona,nroc)
        REFERENCES cliente(zona,nroc)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_idserv FOREIGN KEY (idserv)
        REFERENCES servicio(idserv)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT;

ALTER TABLE referencia
    ADD CONSTRAINT fk_id_serv FOREIGN KEY (idserv)
        REFERENCES servicio(idserv)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    ADD CONSTRAINT fk_zona_nroc FOREIGN KEY (zona,nroc)
        REFERENCES cliente(zona,nroc)
        ON UPDATE SET NULL
        ON DELETE RESTRICT;