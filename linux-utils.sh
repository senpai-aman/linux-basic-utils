#!/usr/bin/sh
#USAGE : 
#./linux-utils.sh [OPTIONS]
#ex : ./linux-utils.sh DEBLOAT=NO
#ex : ./linux-utils.sh ALL
#By default, all options are disabled
#OPTIONS : 
#DEBLOAT=YES : Debloat the unrequired apps
#INSTALL_UTILS=YES : Installing the basic utils
#FLATPAK_APPS=YES : Installing flatpak apps
#ALL=YES : Enables all the options

# List of supported distributions
distro_db=("fedora" "ubuntu" "debian")
de_db=("gnome" "ubuntu")
options=("DEBLOAT" "INSTALL_UTILS" "FLATPAK_APPS" "ALL")
display_help() {
	echo USAGE : 
	echo ./linux-utils.sh [OPTIONS]
	echo ex : ./linux-utils.sh DEBLOAT=NO
	echo ex : ./linux-utils.sh ALL
	echo By default, all options are disabled
	echo OPTIONS : 
	echo DEBLOAT=YES : Debloat the unrequired apps
	echo INSTALL_UTILS=YES : Installing the basic utils
	echo FLATPAK_APPS=YES : Installing flatpak apps
	echo ALL=YES : Enables all the options
}
check_distro() {
	echo "============================================="
	echo "=========READING THE LINUX DISTRO============"
	echo "============================================="
	# Loop through each distribution in the list
	for distro in "${distro_db[@]}"; do
		# Check if the distribution is mentioned in /etc/os-release
		if grep -qi "$distro" /etc/os-release; then
			my_distro=$distro
			echo "============================================="
			echo "DISTRO : $my_distro"
			echo "============================================="
			break  # Exiting the loop once a match is found
		fi
	done

}
check_de() {
	echo "============================================="
	echo "=======READING THE DESKTOP ENVIRONMENT======="
	echo "============================================="
	if [ "$XDG_CURRENT_DESKTOP" ]; then
		xdg_current_desktop=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')
		# Loop through each de in the list
		for de in "${de_db[@]}"; do
			# Check if the
			if [ $de == $xdg_current_desktop ] ; then
				my_de=$de
				echo "============================================="
				echo "DESKTOP ENVIRONMENT : $my_de"
				echo "============================================="
				break  # Exiting the loop once a match is found
			fi
		done
	else
		echo "*********************************************"
		echo "*********NOT ABLE TO DETECT DISTRO***********"
		echo "*********************************************"
	fi
	
}
debloat() {
	echo "============================================="
	echo "==========DEBLOATING_THE_SYSTEM=============="
	echo "============================================="
	case "$my_de" in
		gnome)
			echo "============================================="
			sudo $pkg_mgr -y $uninstall_arg gnome-2048 aisleriot atomix gnome-chess gnome-contacts five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg gnome-maps gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex evolution gnome-weather; 
			echo "============================================="
			;;
		*)
			echo "*********************************************"
			echo "DE NOT SUPPORTED : $my_de"
			echo "*********************************************"
			;;
	esac
}
enable_all() {
	echo "ENABLING ALL OPTIONS"
	for opt in "${options[@]}"; do
		eval "$opt=YES"
	done
}
flatpak_apps() {
	if which flatpak >/dev/null 2>&1; then
		echo "============================================="
		echo "=========INSTALLING_FLATPAK_APPS============="
		echo "============================================="
		#VLC
		#flatpak install -y org.videolan.VLC

		#Gnome-Extension Manager
		#flatpak install -y com.mattjakeman.ExtensionManager

		#Google-Chrome
		flatpak install -y com.google.Chrome

		#Brave
		flatpak install -y com.brave.Browser

		#LibreWolf
		flatpak install -y io.gitlab.librewolf-community

		#Telegram Desktop
		flatpak install -y org.telegram.desktop

		#flatseal
		flatpak install -y com.github.tchx84.Flatseal


	else
		echo "*********************************************"
		echo "********FLATPAK_IS_NOT_INSTALLED*************"
		echo "*********************************************"
	fi
}
install_utils() {
	echo "============================================="
	echo "=============INSTALLING_UTILS================"
	echo "============================================="
	case "$my_distro" in
		fedora)
			echo "============================================="
			#sudo $pkg_mgr -y install <pkg_name>
			#Installing VLC
			sudo $pkg_mgr -y install vlc
			sudo $pkg_mgr -y install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
			#sudo $pkg_mgr -y install lame\* --exclude=lame-devel
			#sudo $pkg_mgr -y group upgrade --with-optional Multimedia

			#Installing useful utils
			sudo $pkg_mgr -y install vim
			sudo $pkg_mgr -y install p7zip-plugins
			sudo $pkg_mgr -y install tldr
			#sudo $pkg_mgr -y install
			echo "============================================="
			;;
		*)
			echo "*********************************************"
			echo "DISTRO NOT SUPPORTED : $my_distro"
			echo "*********************************************"
			exit 1;
			;;
	esac
}
set_pkg_mgr() {
	case "$my_distro" in
		fedora)
			pkg_mgr=dnf
			uninstall_arg="remove"
			echo "============================================="
			echo "PKG_MGR : $pkg_mgr"
			echo "============================================="
			;;
		*)
			echo "*********************************************"
			echo "DISTRO NOT SUPPORTED : $my_distro"
			echo "*********************************************"
			exit 1;
			;;
	esac
}
read_args() {
	#Loop through all arguments
	for arg in "$@"; do
		# Split argument into key and value using '=' as delimiter
		key="${arg%%=*}"
		value="${arg#*=}"

		# Check the key and take action
		case "$key" in
			DEBLOAT)
				echo "DEBLOAT IS $value"
				DEBLOAT="$value"
				;;
			INSTALL_UTILS)
				echo "INSTALL_UTILS IS $value"
				INSTALL_UTILS="$value"
				;;
			FLATPAK_APPS)
				FLATPAK_APPS="$value"
				;;
			ALL)
				ALL="$value"
				if [ $ALL == "YES" ] ; then
					enable_all
					break
				fi
				;;
			*)
				echo "*********************************************"
				echo "Unknown argument: $key"
				echo "*********************************************"
				;;
		esac
	done
	echo "============================================="
	echo "===============OPTIONS_PROVIDED=============="
	echo "============================================="
	for i in "${!options[@]}"; do
		opt="${options[$i]}"
		echo "$opt : ${!opt}"
	done
}
# Check if --help is passed as an argument
if [[ "$1" == "--help" ]]; then
    display_help
    exit 0  # Exit the script after displaying the help message
fi
check_distro
check_de
read_args "$@"
if [ $my_distro ] && [ $my_de ] ; then
	set_pkg_mgr
	if [ "$DEBLOAT" == "YES" ] ; then
		debloat
	fi
	if [ "$INSTALL_UTILS" == "YES" ] ; then
		install_utils	
	fi
	if [ "$FLATPAK_APPS" == "YES" ] ; then
		flatpak_apps	
	fi

fi

