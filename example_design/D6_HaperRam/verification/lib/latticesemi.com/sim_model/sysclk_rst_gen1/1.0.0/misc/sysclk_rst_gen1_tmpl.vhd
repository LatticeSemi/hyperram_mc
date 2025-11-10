component sysclk_rst_gen1 is
    port(
        dut_clk_i: in std_logic;
        dut_rst_i: in std_logic;
        dut_clk_o: out std_logic;
        dut_rst_o: out std_logic;
        tb_rst_o: out std_logic;
        tb_clk_o: out std_logic
    );
end component;

__: sysclk_rst_gen1 port map(
    dut_clk_i=>,
    dut_rst_i=>,
    dut_clk_o=>,
    dut_rst_o=>,
    tb_rst_o=>,
    tb_clk_o=>
);
