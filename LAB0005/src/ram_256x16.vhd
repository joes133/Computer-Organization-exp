-- ram_256x16.vhd
-- Data RAM: 256 words x 16 bits
-- Single-port RAM, write-first mode, initialized from ram_init.mif

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity ram_256x16 is
    port (
        address : in  std_logic_vector(7 downto 0);
        clock   : in  std_logic;
        data    : in  std_logic_vector(15 downto 0);
        wren    : in  std_logic;
        q       : out std_logic_vector(15 downto 0)
    );
end entity ram_256x16;

architecture syn of ram_256x16 is
    signal sub_wire0 : std_logic_vector(15 downto 0);
begin
    q <= sub_wire0;

    altsyncram_component : altsyncram
        generic map (
            clock_enable_input_a          => "BYPASS",
            clock_enable_output_a         => "BYPASS",
            intended_device_family        => "Cyclone V",
            lpm_hint                      => "ENABLE_RUNTIME_MOD=NO",
            lpm_type                      => "altsyncram",
            numwords_a                    => 256,
            operation_mode                => "SINGLE_PORT",
            outdata_aclr_a                => "NONE",
            outdata_reg_a                 => "CLOCK0",
            read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
            widthad_a                     => 8,
            width_a                       => 16,
            width_byteena_a               => 1,
            init_file                     => "mif/ram_init.mif"
        )
        port map (
            clock0    => clock,
            address_a => address,
            data_a    => data,
            wren_a    => wren,
            q_a       => sub_wire0
        );

end architecture syn;
