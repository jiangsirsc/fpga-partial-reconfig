
my $cable_number = $ARGV[0];
my $soffile = "../../output_files/a10_pcie_devkit_cvp.sof";

my $cof = <<END;
<?xml version="1.0" encoding="US-ASCII" standalone="yes"?>
<cof>
        <eprom_name>CFI_2GB</eprom_name>
        <output_filename>flash.pof</output_filename>
        <n_pages>1</n_pages>
        <width>1</width>
        <mode>12</mode>
        <sof_data>
                <start_address>00200000</start_address>
                <user_name>Page_0</user_name>
                <page_flags>1</page_flags>
                <bit0>
                        <sof_filename>$soffile</sof_filename>
                </bit0>
        </sof_data>
        <version>10</version>
        <create_cvp_file>0</create_cvp_file>
        <create_hps_iocsr>0</create_hps_iocsr>
        <auto_create_rpd>0</auto_create_rpd>
        <rpd_little_endian>1</rpd_little_endian>
        <options>
                <map_file>1</map_file>
                <option_start_address>180000</option_start_address>
                <dynamic_compression>0</dynamic_compression>
        </options>
        <advanced_options>
                <ignore_epcs_id_check>0</ignore_epcs_id_check>
                <ignore_condone_check>2</ignore_condone_check>
                <plc_adjustment>0</plc_adjustment>
                <post_chain_bitstream_pad_bytes>-1</post_chain_bitstream_pad_bytes>
                <post_device_bitstream_pad_bytes>-1</post_device_bitstream_pad_bytes>
                <bitslice_pre_padding>1</bitslice_pre_padding>
        </advanced_options>
</cof>
END

my $cdf = <<CDFEND;
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(10AX115S2E2) MfrSpec(OpMask(0));
	P ActionCode(Ign)
		Device PartName(5M2210Z) MfrSpec(OpMask(0) SEC_Device(CFI_2GB) Child_OpMask(3 1 1 1) PFLPath("flash.pof"));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
CDFEND

open COFFILE, ">flash.cof";
print COFFILE $cof;
close COFFILE;

system ("quartus_cpf --convert flash.cof");
$? == 0  or die "Error: quartus_cpf failed";

open CDFFILE, ">flash.cdf";
print CDFFILE $cdf;
close CDFFILE;
system ("jtagconfig --setparam $cable_number JtagClock 6M");
$? == 0  or die "Error: Jtag Clock setting failed";

system ("quartus_pgm -c $cable_number flash.cdf");
$? == 0  or die "Error: quartus_pgm failed";
