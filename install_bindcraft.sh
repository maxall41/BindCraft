#!/bin/bash
################## BindCraft installation script
################## specify conda/mamba folder, and installation folder for git repositories, and whether to use mamba or $pkg_manager
# Default value for pkg_manager
pkg_manager='conda'
cuda=''

# Define the short and long options
OPTIONS=p:c:
LONGOPTIONS=pkg_manager:,cuda:

# Parse the command-line options
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
eval set -- "$PARSED"

# Process the command-line options
while true; do
  case "$1" in
    -p|--pkg_manager)
      pkg_manager="$2"
      shift 2
      ;;
    -c|--cuda)
      cuda="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option $1" >&2
      exit 1
      ;;
  esac
done

# Example usage of the parsed variables
echo "Package manager: $pkg_manager"
echo "CUDA version (if provided): $cuda"

############################################################################################################
############################################################################################################
################## initialisation
SECONDS=0

# set paths
install_dir=/root/bindcraft/

### BindCraft install
printf "Installing BindCraft environment\n"

# install required packages
if [ -n "$cuda" ]; then
    CONDA_OVERRIDE_CUDA="$cuda" $pkg_manager install pip pandas matplotlib numpy"<2.0.0" biopython scipy pdbfixer seaborn tqdm jupyter ffmpeg pyrosetta fsspec py3dmol chex dm-haiku dm-tree joblib ml-collections immutabledict optax jaxlib=*=*cuda* jax cuda-nvcc cudnn -c conda-forge -c anaconda -c nvidia  --channel https://conda.graylab.jhu.edu -y
else
    $pkg_manager install pip pandas matplotlib numpy"<2.0.0" biopython scipy pdbfixer seaborn tqdm jupyter ffmpeg pyrosetta fsspec py3dmol chex dm-haiku dm-tree joblib ml-collections immutabledict optax jaxlib jax cuda-nvcc cudnn -c conda-forge -c anaconda -c nvidia  --channel https://conda.graylab.jhu.edu -y
fi

# install ColabDesign
printf "Installing ColabDesign"
pip3 install git+https://github.com/sokrypton/ColabDesign.git --no-deps

# Download AlphaFold2 weights
mkdir -p ${install_dir}/params/
cd ${install_dir}/params/
printf "Downaloding files"
wget -P ${install_dir}/params/ https://storage.googleapis.com/alphafold/alphafold_params_2022-12-06.tar
tar -xvf ${install_dir}/params/alphafold_params_2022-12-06.tar
printf "Finished downloading files"
# chmod executables
chmod +x ${install_dir}/functions/dssp
chmod +x ${install_dir}/functions/DAlphaBall.gcc

############################################################################################################
############################################################################################################
################## cleanup
printf "Cleaning up ${pkg_manager} temporary files to save space\n"
$pkg_manager clean -a -y
printf "$pkg_manager cleaned up\n"

################## finish script
t=$SECONDS 
printf "Installation took $(($t / 3600)) hours, $((($t / 60) % 60)) minutes and $(($t % 60)) seconds."
