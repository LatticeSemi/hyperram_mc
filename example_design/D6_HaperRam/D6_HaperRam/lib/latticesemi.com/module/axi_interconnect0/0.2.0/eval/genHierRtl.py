# =============================================================================
# >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# -----------------------------------------------------------------------------
#   Copyright (c) 2017 by Lattice Semiconductor Corporation
#   ALL RIGHTS RESERVED
# -----------------------------------------------------------------------------
#
#   Permission:
#
#      Lattice SG Pte. Ltd. grants permission to use this code
#      pursuant to the terms of the Lattice Reference Design License Agreement.
#
#
#   Disclaimer:
#
#      This VHDL or Verilog source code is intended as a design reference
#      which illustrates how these types of functions can be implemented.
#      It is the user's responsibility to verify their design for
#      consistency and functionality through the use of formal
#      verification methods.  Lattice provides no warranty
#      regarding the use or functionality of this code.
#
# ------------------------------------------------------------------------------
#
#                  Lattice SG Pte. Ltd.
#                  101 Thomson Road, United Square #07-02
#                  Singapore 307591
#
#
#                  TEL: 1-800-Lattice (USA and Canada)
#                       +65-6631-2000 (Singapore)
#                       +1-503-268-8001 (other locations)
#
#                  web: http://www.latticesemi.com/
#                  email: techsupport@latticesemi.com
#
# ------------------------------------------------------------------------------
#
# ==============================================================================
#                         FILE DETAILS
# Project               : 
# File                  : genHierRtl.py
# Title                 :
# Dependencies          : 1.
#                       : 2.
# Description           :
# ==============================================================================
#                        REVISION HISTORY
# Version               : 1.0
# Author(s)             :
# Mod. Date             :
# Changes Made          :
# ==============================================================================

'''  
  This script is used to generate the rtl of axi_hier design and regenerate the subcomponents .
  Current script contains some definitions from the design, if design is modified, please update this script as well.

  Use add_regen_instance(instance_name, relative_install_path) to add or update components that need to regenerate in main.

'''

import subprocess
import os
import sys
import json
from lxml import objectify, etree


# subcomponents need to regenerate
SUB_COM_DICT = {}
# sub library path
DESIGN_SEARCH_PATH = ""
 
# ipxact2rtl path 
GEN_RTL_EXE= "ipxact2rtl"
# ipgen path
IPGEN_EXE = "ipgen"
# builder install foundry path
FOUNTRY = os.environ["FOUNDRY"]

def generate_component(device_info, meta_path, com_name, com_path, config_values):  
    # gen sub components
    hier_inst_path = os.path.realpath(os.path.dirname(sys.argv[0]) + "/..")
    global IPGEN_EXE
    global FOUNTRY
    gen_ip_args = list()
    gen_ip_args.append(IPGEN_EXE)
    gen_ip_args.append("-a")
    gen_ip_args.append(device_info["ARCHITECTURE"])
    gen_ip_args.append("-p")
    gen_ip_args.append(device_info["DEVICE"])
    gen_ip_args.append("-t")
    gen_ip_args.append(device_info["PACKAGE"])
    gen_ip_args.append("-sp")
    gen_ip_args.append(device_info["PERFORMANCE"])
    gen_ip_args.append("-f")
    gen_ip_args.append(device_info["FAMILY"])
    gen_ip_args.append("-platform")
    gen_ip_args.append("Propel")
    os.environ["PATH"] = FOUNTRY + "/../bin/nt64;" + FOUNTRY + "/bin/nt64;" + os.environ["PATH"]

    gen_bridge_args = list()
    gen_bridge_args.append("-o")
    gen_bridge_args.append(com_path)
    gen_bridge_args.append("-proj_dir")
    gen_bridge_args.append(com_path)
    gen_bridge_args.append("-ip")
    gen_bridge_args.append(meta_path)
    gen_bridge_args.append("-name")
    gen_bridge_args.append(com_name)
    for key, value in config_values.items():
        gen_bridge_args.append("-cfg_value")
        gen_bridge_args.append(key + ":" + str(value))    
    subprocess.call(gen_ip_args + gen_bridge_args)


def gen_hier_rtl(gen_rtl_exe):
    gen_rtl_args = list()
    gen_rtl_args.append(gen_rtl_exe)
    gen_rtl_args.append("--hier")
    gen_rtl_args.append("-p")
    gen_rtl_args.append(hier_inst_path)
    subprocess.call(gen_rtl_args)


def get_meta_vlnv(metadata):
    meta_doc = objectify.parse(metadata)
    meta_root = meta_doc.getroot()
    vlnv = dict()
    vlnv["vendor"] = meta_root.general.vendor.text
    vlnv["library"] = meta_root.general.library.text
    vlnv["name"] = meta_root.general.name.text
    vlnv["version"] = str(meta_root.general.version.text)
    
    objectify.deannotate(meta_root)
    etree.cleanup_namespaces(meta_root)
    
    return vlnv
 

def get_component_device_info(com_path):
    com_doc = objectify.parse(com_path+ "/component.xml")
    com_root = com_doc.getroot()
    device_info = dict()
    for child in com_root.vendorExtensions.getchildren():
        if child.tag.endswith("deviceInfo"):
            device_info["ARCHITECTURE"] = child.architecture.text
            device_info["DEVICE"] = child.device.text
            device_info["PACKAGE"] = child.package.text
            device_info["PERFORMANCE"] = child.performanceGrade.text
            if hasattr(child, "family"):
                device_info["FAMILY"] = child.family.text
            else:
                device_info["FAMILY"] = child.architecture.text
            break
   
    objectify.deannotate(com_root)
    etree.cleanup_namespaces(com_root)

    return device_info

 
## merge old config values and new config values, new will overwrite old items.
#
# @param hier_inst_path: Design.xml directory
# @param inst_name_list: Instance name list from design.
# 
#  return values:
#    first : inst_com_dict[inst_name] = com_name
#    second: result[com_name] = {"setting_id": value, "setting_id1": value}
def get_config_value(hier_inst_path, inst_name_list):
    design_doc = objectify.parse(hier_inst_path + "/design.xml")
    design_root = design_doc.getroot()
    
    result = {}
    inst_com_dict = {}
    design_namespace = design_root.nsmap
    for key, value in design_namespace.items():
        etree.register_namespace(key, value)
    global DESIGN_SEARCH_PATH      
    DESIGN_SEARCH_PATH = hier_inst_path
    if hasattr(design_root, "vendorExtensions"):
        exts = design_root.vendorExtensions
        for ext in exts.getchildren():
            if ext.tag.endswith("libSearchPath"):
                DESIGN_SEARCH_PATH = os.path.join(DESIGN_SEARCH_PATH, ext.libPath.text)
        
    for instance in design_root.componentInstances.getchildren():

        
        inst_name = instance.instanceName.text
        com_ref = instance.componentRef
        com_vendor = com_ref.attrib["vendor"]
        com_lib = com_ref.attrib["library"]
        com_name = com_ref.attrib["name"]
        com_version = com_ref.attrib["version"]
        
        inst_com_dict[inst_name] = com_name
        if inst_name in inst_name_list:
            inst_config_values = {}
            
            # get old config values 
            com_path = DESIGN_SEARCH_PATH + "/" + com_vendor + "/" + com_lib + "/" + com_name + "/" + com_version
            com_cfg = com_path + "/" + com_name + ".cfg"
            with open(com_cfg,'r') as load_f:
                load_dict = json.load(load_f)
                for key, value in load_dict.items():
                    inst_config_values[key]=value
            
            # get new config values in design 
            if hasattr(com_ref, "configurableElementValues"):
                for child in com_ref.configurableElementValues.getchildren():
                    if child.tag.endswith("configurableElementValue"):
                        inst_config_values[child.attrib["referenceId"]] = str(child.text)
            
            if len(inst_config_values) > 0:
                result[inst_name] = inst_config_values   
        else: 
            continue
    
    objectify.deannotate(design_root)
    etree.cleanup_namespaces(design_root)

    return inst_com_dict, result
    
 
def gen_sub_component(hier_inst_path):
    device_info = get_component_device_info(hier_inst_path)
    inst_com_dict, config_values_dict = get_config_value(hier_inst_path, SUB_COM_DICT.keys())
    for inst_name, meta_path in SUB_COM_DICT.items():
        new_vlnv = get_meta_vlnv(SUB_COM_DICT[inst_name] + "/metadata.xml")
        new_com_path = os.path.join(DESIGN_SEARCH_PATH, new_vlnv["vendor"], new_vlnv["library"], inst_com_dict[inst_name],new_vlnv["version"])
        if not os.path.exists(new_com_path):
            print("new version with", new_vlnv)
            os.mkdir(new_com_path)
        generate_component(device_info, meta_path, inst_com_dict[inst_name], new_com_path, config_values_dict[inst_name])
 

def init_global_variables():
    global IPGEN_EXE
    global GEN_RTL_EXE
    global FOUNTRY
    if "" == FOUNTRY:
        exit
    
    if "" != FOUNTRY:
       plat = sys.platform
       pos = plat.find("linux")
       if -1 == pos:
           GEN_RTL_EXE = os.path.join(FOUNTRY, "..", "bin", "nt64", GEN_RTL_EXE)
           IPGEN_EXE = os.path.join(FOUNTRY, "bin", "nt64", IPGEN_EXE)
       else:
           GEN_RTL_EXE = os.path.join(FOUNTRY, "..", "bin", "lin64", GEN_RTL_EXE)
           IPGEN_EXE = os.path.join(FOUNTRY, "bin", "lin64", IPGEN_EXE)


## Add instance to global variable that need to regenerate in hier design.
#
# @param instance_name: instance's name in design.xml -> componentInstance -> instanceName
# @param relative_install_path: relative path to rtf/ip
def add_regen_instance(instance_name, relative_install_path):
    global FOUNTRY
    module_path = os.path.realpath(FOUNTRY + "/../ip")
    SUB_COM_DICT[instance_name] = os.path.realpath(module_path + "/" + relative_install_path)


if __name__ == '__main__':

    if not os.path.exists(sys.argv[0]):
        exception('instance path not exists!!!')
    init_global_variables()
    
    add_regen_instance("axi_crossbarNxM_inst", "axi/axi_crossbar")

    hier_inst_path = os.path.realpath(os.path.dirname(sys.argv[0]) + "/..")
    gen_sub_component(hier_inst_path)
    gen_hier_rtl(GEN_RTL_EXE)