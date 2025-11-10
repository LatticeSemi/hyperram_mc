component uart_model1 is
    port(
        clk: in std_logic;
        rstn: in std_logic;
        uart_rxd: in std_logic;
        uart_txd: out std_logic;
        uart_rx_data_debug: out std_logic_vector(7 downto 0);
        uart_rx_valid_debug: out std_logic;
        uart_rx_break_debug: out std_logic;
        uart_tx_data_debug: out std_logic_vector(7 downto 0);
        uart_tx_en_debug: out std_logic;
        uart_tx_busy_debug: out std_logic
    );
end component;

__: uart_model1 port map(
    clk=>,
    rstn=>,
    uart_rxd=>,
    uart_txd=>,
    uart_rx_data_debug=>,
    uart_rx_valid_debug=>,
    uart_rx_break_debug=>,
    uart_tx_data_debug=>,
    uart_tx_en_debug=>,
    uart_tx_busy_debug=>
);
