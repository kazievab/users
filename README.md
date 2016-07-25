# Users DB Manager using Mojolicious

A project using Mojolicious framework no lite, Bootstrap, SQLite

# Install

	git clone git://github.com/kazievab/users.git users
	cd users


Install the Carton package manager. Carton will install all dependencies
to the local/ sub-directory.

		curl -L cpanmin.us | perl - Carton
 	or
		cpanm Carton
 	and
		carton install

# Run
	carton exec morbo script/users
