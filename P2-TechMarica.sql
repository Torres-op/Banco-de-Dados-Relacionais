DROP DATABASE IF EXISTS db_techmarica;
CREATE DATABASE db_techmarica;
USE db_techmarica;

CREATE TABLE funcionarios (
    id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    area_atuacao VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    situacao ENUM('ATIVO', 'INATIVO') DEFAULT 'ATIVO'
);

CREATE TABLE maquinas (
    id_maquina INT PRIMARY KEY AUTO_INCREMENT,
    nome_maquina VARCHAR(100) NOT NULL,
    codigo_serie VARCHAR(50) UNIQUE NOT NULL,
    status_operacional ENUM('OPERANDO', 'MANUTENCAO', 'DESATIVADA') DEFAULT 'OPERANDO'
);

CREATE TABLE produtos (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    codigo_interno VARCHAR(20) UNIQUE NOT NULL,
    nome_comercial VARCHAR(100) NOT NULL,
    id_responsavel_tecnico INT NOT NULL,
    custo_producao DECIMAL(10, 2) NOT NULL,
    data_cadastro DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (id_responsavel_tecnico) REFERENCES funcionarios(id_funcionario)
);

CREATE TABLE ordens_producao (
    id_ordem INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL,
    id_maquina INT NOT NULL,
    id_funcionario_autorizador INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_conclusao DATE,
    status_ordem ENUM('EM PRODUÇÃO', 'FINALIZADA', 'CANCELADA') DEFAULT 'EM PRODUÇÃO',
    quantidade_produzida INT DEFAULT 0,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    FOREIGN KEY (id_maquina) REFERENCES maquinas(id_maquina),
    FOREIGN KEY (id_funcionario_autorizador) REFERENCES funcionarios(id_funcionario)
);

INSERT INTO funcionarios (nome, area_atuacao, situacao, email) VALUES
('Carlos Silva Santos', 'Engenharia', 'ATIVO', 'carlos.silva@techmarica.com'),
('Ana Paula Oliveira', 'Produção', 'ATIVO', 'ana.oliveira@techmarica.com'),
('Roberto Lima Costa', 'Qualidade', 'INATIVO', 'roberto.lima@techmarica.com'),
('Juliana Ferreira', 'Manutenção', 'ATIVO', 'juliana.ferreira@techmarica.com'),
('Pedro Henrique Souza', 'Engenharia', 'ATIVO', 'pedro.souza@techmarica.com');

INSERT INTO maquinas (nome_maquina, codigo_serie, status_operacional) VALUES
('Linha de Montagem A1', 'LMA-2019-001', 'OPERANDO'),
('Estação de Soldagem S2', 'ESS-2020-045', 'OPERANDO'),
('Centro de Usinagem CNC', 'CNC-2021-078', 'MANUTENCAO');

INSERT INTO produtos (codigo_interno, nome_comercial, id_responsavel_tecnico, custo_producao, data_cadastro) VALUES
('SENS-2023-001', 'Sensor de Temperatura IoT', 1, 45.50, '2023-01-15'),
('PCB-2023-002', 'Placa Controladora Smart', 1, 120.75, '2023-03-20'),
('MOD-2023-003', 'Módulo WiFi Industrial', 5, 89.90, '2023-05-10'),
('SENS-2023-004', 'Sensor de Pressão Digital', 5, 65.30, '2023-07-25'),
('PCB-2024-005', 'Placa de Interface USB', 2, 52.00, '2024-02-14');

INSERT INTO ordens_producao (id_produto, id_maquina, id_funcionario_autorizador, data_inicio, data_conclusao, status_ordem, quantidade_produzida) VALUES
(1, 1, 1, '2024-10-01', '2024-10-15', 'FINALIZADA', 500),
(2, 2, 2, '2024-10-05', '2024-10-20', 'FINALIZADA', 300),
(3, 1, 1, '2024-10-10', NULL, 'EM PRODUÇÃO', 0),
(4, 3, 4, '2024-10-12', NULL, 'EM PRODUÇÃO', 0),
(5, 2, 2, '2024-10-18', '2024-11-01', 'FINALIZADA', 450),
(1, 1, 5, '2024-11-05', NULL, 'EM PRODUÇÃO', 0);

SELECT 
    op.id_ordem,
    p.codigo_interno,
    p.nome_comercial AS produto,
    m.nome_maquina AS maquina,
    f.nome AS funcionario_autorizador,
    op.data_inicio,
    op.data_conclusao,
    op.status_ordem,
    op.quantidade_produzida
FROM ordens_producao op
INNER JOIN produtos p ON op.id_produto = p.id_produto
INNER JOIN maquinas m ON op.id_maquina = m.id_maquina
INNER JOIN funcionarios f ON op.id_funcionario_autorizador = f.id_funcionario
ORDER BY op.data_inicio;

SELECT 
    nome,
    area_atuacao,
    email,
    situacao
FROM funcionarios
WHERE situacao = 'INATIVO';

SELECT 
    f.nome AS responsavel_tecnico,
    f.area_atuacao,
    COUNT(*) AS total_produtos
FROM funcionarios f
LEFT JOIN produtos p ON f.id_funcionario = p.id_responsavel_tecnico
GROUP BY f.id_funcionario, f.nome, f.area_atuacao
ORDER BY total_produtos DESC;

SELECT 
    codigo_interno,
    nome_comercial,
    custo_producao,
    data_cadastro
FROM produtos
WHERE nome_comercial LIKE 'S%'
ORDER BY nome_comercial;

SELECT 
    codigo_interno,
    nome_comercial,
    data_cadastro,
    TIMESTAMPDIFF(YEAR, data_cadastro, CURDATE()) AS idade_anos
FROM produtos
ORDER BY data_cadastro;

SELECT 
    codigo_interno,
    nome_comercial,
    custo_producao,
    CONCAT('R$ ', FORMAT(custo_producao, 2, 'pt_BR')) AS custo_formatado
FROM produtos
ORDER BY custo_producao DESC
LIMIT 3;

SELECT 
    status_ordem,
    COUNT(*) AS total_ordens,
    SUM(quantidade_produzida) AS total_pecas
FROM ordens_producao
GROUP BY status_ordem;

SELECT 
    op.id_ordem,
    p.nome_comercial,
    op.data_inicio,
    DATEDIFF(CURDATE(), op.data_inicio) AS dias_em_producao
FROM ordens_producao op
INNER JOIN produtos p ON op.id_produto = p.id_produto
WHERE op.status_ordem = 'EM PRODUÇÃO' 
  AND DATEDIFF(CURDATE(), op.data_inicio) > 30;

CREATE OR REPLACE VIEW vw_relatorio_producao AS
SELECT 
    op.id_ordem,
    p.codigo_interno AS cod_produto,
    p.nome_comercial AS produto,
    p.custo_producao,
    m.nome_maquina AS maquina,
    m.status_operacional AS status_maquina,
    f.nome AS responsavel_autorizacao,
    f.area_atuacao,
    op.data_inicio,
    op.data_conclusao,
    op.status_ordem,
    op.quantidade_produzida,
    CASE 
        WHEN op.data_conclusao IS NOT NULL 
        THEN DATEDIFF(op.data_conclusao, op.data_inicio)
        ELSE DATEDIFF(CURDATE(), op.data_inicio)
    END AS dias_producao,
    (op.quantidade_produzida * p.custo_producao) AS custo_total_lote
FROM ordens_producao op
INNER JOIN produtos p ON op.id_produto = p.id_produto
INNER JOIN maquinas m ON op.id_maquina = m.id_maquina
INNER JOIN funcionarios f ON op.id_funcionario_autorizador = f.id_funcionario;

SELECT * FROM vw_relatorio_producao WHERE status_ordem = 'EM PRODUÇÃO';

DELIMITER $$

CREATE PROCEDURE sp_registrar_ordem_producao(
    IN p_id_produto INT,
    IN p_id_funcionario INT,
    IN p_id_maquina INT,
    OUT p_mensagem VARCHAR(200)
)
BEGIN
    DECLARE v_produto_existe INT;
    DECLARE v_funcionario_existe INT;
    DECLARE v_maquina_existe INT;
    
    SELECT COUNT(*) INTO v_produto_existe 
    FROM produtos WHERE id_produto = p_id_produto;
    
    SELECT COUNT(*) INTO v_funcionario_existe 
    FROM funcionarios WHERE id_funcionario = p_id_funcionario;
    
    SELECT COUNT(*) INTO v_maquina_existe 
    FROM maquinas WHERE id_maquina = p_id_maquina;
    
    IF v_produto_existe = 0 THEN
        SET p_mensagem = 'ERRO: Produto não encontrado!';
    ELSEIF v_funcionario_existe = 0 THEN
        SET p_mensagem = 'ERRO: Funcionário não encontrado!';
    ELSEIF v_maquina_existe = 0 THEN
        SET p_mensagem = 'ERRO: Máquina não encontrada!';
    ELSE
        INSERT INTO ordens_producao (
            id_produto, 
            id_maquina, 
            id_funcionario_autorizador, 
            data_inicio, 
            status_ordem
        ) VALUES (
            p_id_produto, 
            p_id_maquina, 
            p_id_funcionario, 
            CURDATE(), 
            'EM PRODUÇÃO'
        );
        
        SET p_mensagem = CONCAT('SUCESSO: Ordem #', LAST_INSERT_ID(), ' criada em ', CURDATE());
    END IF;
END$$

DELIMITER ;

CALL sp_registrar_ordem_producao(1, 1, 2, @msg);
SELECT @msg AS mensagem;

DELIMITER $$

CREATE TRIGGER trg_finalizar_ordem
BEFORE UPDATE ON ordens_producao
FOR EACH ROW
BEGIN
    IF OLD.data_conclusao IS NULL AND NEW.data_conclusao IS NOT NULL THEN
        SET NEW.status_ordem = 'FINALIZADA';
    END IF;
END$$

DELIMITER ;

UPDATE ordens_producao 
SET data_conclusao = CURDATE(), quantidade_produzida = 600
WHERE id_ordem = 3;

SELECT id_ordem, status_ordem, data_conclusao FROM ordens_producao WHERE id_ordem = 3;

SELECT 
    m.nome_maquina,
    COUNT(op.id_ordem) AS total_ordens,
    SUM(op.quantidade_produzida) AS total_producao,
    AVG(op.quantidade_produzida) AS media_producao
FROM maquinas m
LEFT JOIN ordens_producao op ON m.id_maquina = op.id_maquina
GROUP BY m.id_maquina, m.nome_maquina;

SELECT 
    f.nome,
    COUNT(op.id_ordem) AS ordens_autorizadas,
    f.area_atuacao
FROM funcionarios f
INNER JOIN ordens_producao op ON f.id_funcionario = op.id_funcionario_autorizador
GROUP BY f.id_funcionario, f.nome, f.area_atuacao
ORDER BY ordens_autorizadas DESC;