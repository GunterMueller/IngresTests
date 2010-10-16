#!/bin/sh
#
#		SCRIPT TO RUN FRONTEND SEP TESTS 
#
# History:
#	19-May-92 (GordonW)
#		Gneralized output logic
#		added arg1 to specify individual test groups.
#	26-Jun-92 (barbh)
#		Remove code that filters the .lis files. If a test is
#		not to be run, the .lis file will be changed to reflect
#		that. 
#	07-08-92  (barbh)
#		Changed rbf initialization area to use SEPPARAMDB=rbfdbb
#		and SEPPARAMDB1=rbfdba. "rbfdba" is needed for test
#		rga02.sep.
#	07-14-92  (barbh)
#		Added a sep test to the qbf initialization area. The 
#		following sep test must be run so that qbf1 database
#		will have all the tables used by the qbf sep tests.
#		$TST_INIT/bsopnld.sep
#	09-18-92  (barbh)
#		Added logic to create sub-directories under
#		$ING_TST/output. These sub-directories will be used to 
#		hold the report,log, and out files generated by listexec.
#		Changed the logical $OUT_LOG to be $TST_OUTPUT to be 
#		consistent with other shell scripts that run tests.
#	10-1-92   (rodneyy)
#		Added section to run the "feimage" sep tests using the
#		same database as used in the ABF tests.
##	10-09-1992 (gillnh2o)
##		Removed typo from one of the feinit.out's.
##	10-12-1992 (gillnh2o)
##		Added defination of SEPPARAMDB1 to fac = image. 
##		One of the partially automated tests "oga38" requires
##		that the environment variable be set.
##      10-22-1992 (judi)
##              Set umask to 2.
#	10-28-1992 (barbh)
#		Changed name of databases used in image tests. They are
#		now imagedb and imagedb2. This is to prevent accidental
#		removal during testing.
#	01-08-1993 (rodneyy)
#		Changed "qbf.cfg" to "feqbf.cfg" for consistency.
#	24-Feb-93 (barbh)
#		This shell script has been completely overhauled. The new
#		format is as follows:
#		
#		1. Script Setup
#		   a) Revised how TST_OUTPUT is set. This will become an
#		      exported variable for listexec to use.
#		   b) Initializes the "work" variable with the "$1" input
# 		      from the command line.
#		   c) Shell command "shift" is invoked to pick up all other
#		      command line input for the modules to be run.
#
#		2. Initialize Databases
#		   a) Code installed to accept more than one module as 
#		      input from the command line.
#      	   	   b) Databases left as commands to Ingres in the shell
# 		      script. This is to eliminate the need to maintain a
#		      large number of .lis and .cfg files for each database
#		      createdb sep test.
#
#		3. Main working area
#		   a) Code installed to accept more than one module as input
#		      from the command line.
#
#		4. This script can be run as follows:
#		   a) To initialize all databases:
#
#		      sh $TST_SHELL/runfe.sh init all
#
#		   b) To initialize selected databases, choose the modules 
#		      shown between the pipes:
#
#		      sh $TST_SHELL/runfe.sh init |4gl|abf|image|copy|qbf|rbf|
#						   frs|rw|vifred|vision
#
#		   c) To run all Frontend test suites:
#
#		      sh $TST_SHELL/runfe.sh fe all
#
#		   d) To run selected test modules, choose the modules shown
#		      between the pipes:
#		      sh $TST_SHELL/runfe.sh fe |4gl|abf|image|copy|fefutil|
#						 frs|fstm|qbf|rw|rbf|vision|
#						 vifred
#       01-apr-93  (barbh)
#               Added logic to send a message, if during the initilization 
#               of databases, either "all" or a list of modules is not
#               given on the command line input.
#	05-Apr-93  (jpark)
#		Added abfinit.sep line to abf init section.
#	07-apr-93 (barbh)
#		Fixed logic to send error message if initialization is not
# 		requested correctly.
#	22-04-93  (barbh)
#		Added an frs database initialization to the init section of
#		the script. Changed the name of the database used by the frs
#		module from abf4gldb to frsdb.
#	27-apr-93 (jeremyb)
#		Changed two lines from $TST_0UTPUT to $TST_OUTPUT
#		The former contained 0 (zero) instead of O (capital o).
# 		the effected lines were.
#		sep -b $TST_INIT/abfinit.sep -o$TST_0UTPUT
#		sep -b $TST_INIT/bsopnld.sep -o$TST_0UTPUT
#       01-jul-93 (garys)
#               Changed 'forms' to 'fefutil' for consistency.
#	30-aug-93 (jpark)
#		Changed to reflect new init scripts.
#	06-oct-93 (jpark)
#		Changed rw,vifred init section to reflect new init scripts.
#       08-dec-93 (judi)
#               Added or re-added? the destroy/createdb of basisdb under
#	        fstm.  Remove the destroy/createdb of basisdb from rw.
#	21-jan-94 (sandhya)
#		Added -t10 flag to the executor command for running 4gl
#		tests.  This is necessary since four sep tests are
#		guaranteed to abort on Unix platforms since they run
#		only on VMS platforms.  The default test tolerance
#		level for executor is 5.  Thus if one additional test
#		aborts for 4gl suite, the job will be aborted.  This
#		will prevent the job being aborted if no more than
#		10 tests abort.
#	24-jan-94 (judi)
#               Added fe/genutil test area.
#       25-jan-1994 (judi)
#               Remove destroydb/createdb from the fe/genutil area.
#       26-jan-1994 (scotts)
#               Added createdb for COPY and RW INIT sections in
#               case the databases were not created in their 
#               preceding sections (ABF INIT and FSTM INIT).
#       21-apr-1994 (garys)
# 		Added additional database (SEPPARAMDB1, abfdb2, and 
#		initabf2.sep) to init and execution sections for abf.
#		Some of the lia*.sep tests need to use a second database 
#		to test	iiexport/iiimport functionality between two 
#		different databases.  initabf.sep is no longer used to 
#		initialize abfdb1 - initabf1.sep and initabf2.sep are 
#		used instead to initialize databases abfdb1 and abfdb2, 
#		respectively.
#	07-Jun-1994 (garys) Removed vigraph tests since VIGRAPH will not be
#		supported within OpenINGRES.
#       16-Jun-1995 (sheal01)
#               Added creation of output directories for each part of FE 
#		tests in the TST_OUTPUT directory.
#	26-Jun-1995 (somsa01)
#               changed locations for output by adding subdirectories to
#               the output areas.
#       30-Jun-95 (ciodi01)
#               The above change includes the following change:
#               TST_OUTPUT=$TST_ROOT_OUTPUT/be instead of 
#		$TST_ROOT_OUTPUT/output/be.
#               This change is intentional and has been made in most of 
#		the .sh files.
#	21-Aug-95 (wooke01)
#		Undid change above.  Most of the .sh files are still
#		writing to $TST_ROOT_OUTPUT/output/be etc... so
#		changed this back to $TST_ROOT_OUTPUT/output/be to comply
#		with existing .sh files.  This means output is
#		written to the subdirectories created by the
#		tstsetup.sh script.
#	20-Sep-95 (wadag01)
#		The change made by ciodi01 on 30-Jun-95 is reintroduced.
#		Added mkdir for the output directory (to align with other.sh)
#		Added destroydb copydb1 in the COPY section.
#	28-Sep-95 (wadag01)
#		Sorted out the comments section.
#	03-Mar-98 (vande02)
#		Created revized version runfeZ.sh for handoff_qa.  Removed
#		the fefutil suite until these tests are fixed.  They create
#		pointless difs and fut02.sep is not relevent to OI's current
#		functionality (see bug #87619).  Posted issues to folder.
#	04-Jun-98 (vande02)
#		Added Clean Up Area to destroy testing databases
#       07-Jun-1999 (vande02)
#               Added calls to qawtl for messages to be written to errlog.log
#       18-jun-1999 (musro02)
#               Cosmetic changes to echo output
#	11-jan-2000 (vande02)
#           Checking the return code for each database initialization step, so
#           if the createdb fails, the script will echo a message and exit.
#       24-mar-2000 (vande02)
#           Added the destroydb rwdb under the initialization section so that
#           the rwdb can successfully be recreated.
#       20-jul-2000 (vande02)
#           Changed facility image so that output goes to $TST_OUTPUT/image
#       15-aug-2000 (vande02) 
#           Fix to above fix for image suite
#	07-May-2001 (hanje04)
#	    As part of fix for b104205, the time sep spends sleeping
#	    between diffs can now be controlled by setting the environment
#	    variable DIFF_SLEEP. If it is set too low (depends on platform)
#	    it can cause syncing problems in the FRS,VISION and VIFRED tests. 
#	    To avoid this before the FRS tests are run DIFF_SLEEP is saved, 
#	    unset and then reset after the tests have completed.
#       08-Apr-2005 (vande02)
#           Taking out comment characters for fefutil so you can run fefutil
#	    now that the tests have been cleaned up to the Ingres r3 level.
#       14-Jun-2006 (hanal04)
#           Destroy ima_db before doing fefutil tests to avoid differences
#           caused by BE tests.
#       15-June-2006 (hanal04)
#           Remove incorrect space in -u option of previous change.
#	14-Sep-2006 (bonro01)
#	    Remove garbage left from previous change 482144
#       02-Feb-2009 (sarjo01)
#           Set ING_CHARSET, SEPPARAM_CHARSET.
##	27-Feb-2009 (boija02)
##		Replacing all ING_CHARSET references with SEPPARAM_CHARSET
#
#---------------------------------------------------------------------------
#			Setup Area
#---------------------------------------------------------------------------
umask 2 
umask 

# Set a variable that can be used to check the character set
#
ii_code=`ingprenv II_INSTALLATION`
SEPPARAM_CHARSET=`ingprenv II_CHARSET$ii_code`
export SEPPARAM_CHARSET

# Set the output directory for test results.
#
if [ "$TST_ROOT_OUTPUT" != "" ]
then
	TST_OUTPUT=$TST_ROOT_OUTPUT/fe/local

	if [ ! -d $TST_ROOT_OUTPUT ]
        then
          echo "Creating Directory - $TST_ROOT_OUTPUT"
          echo ""
	  mkdir $TST_ROOT_OUTPUT
        fi

        if [ ! -d $TST_ROOT_OUTPUT/fe ]
        then
          echo "Creating Directory - $TST_ROOT_OUTPUT/fe"
          echo ""
	  mkdir $TST_ROOT_OUTPUT/fe
	fi

else 
	TST_OUTPUT=$ING_TST/output/fe/local

	if [ ! -d $ING_TST/output ]
        then
          echo "Creating Directory - $ING_TST/output"
          echo ""
	  mkdir $ING_TST/output
        fi

	if [ ! -d $ING_TST/output/fe ]
        then
          echo "Creating Directory - $ING_TST/output/fe"
          echo ""
	  mkdir $ING_TST/output/fe
        fi
fi

	if [ ! -d $TST_OUTPUT ]
	then
	  echo "Creating Directory - $TST_OUTPUT"
          echo ""
	  mkdir $TST_OUTPUT
	fi
	export TST_OUTPUT

	echo "Output files will be written to $TST_OUTPUT"
        echo ""
#

if [ ! -d $TST_OUTPUT ]
  then
    echo "Creating Directory - $TST_OUTPUT"
    echo ""
    mkdir $TST_OUTPUT
  fi


# Variable to determine which sep tests to run if running frontend tests
# against STAR database. If false, run all parts of the sep test. If true,
# skip the db proc part of the sep test.

SEPPARAM_STAR=false

# Initialize variable input to shell script

work=$1
shift

# Check for init or clean parameter

if [ "$1" = "init" ]
then 
	work=$1
	shift
fi

if [ "$1" = "clean" ]
then 
	work=$1
	shift
fi

#-------------------------------------------------------------------------------#			End of Setup
#-------------------------------------------------------------------------------#
#------------------------------------------------------------------------------
#			Initialization Area
#------------------------------------------------------------------------------
#
if [ "$work" = "init" ]
then
    if [ "$*" = "" ]
    then
  	    echo "You must input the modules to be initalized "
	    echo "or specify ""all""."
	    echo ""
	    echo " Example: sh $TST_SHELL/runfe.sh init all "
	    echo ""
	    echo "          or "
	    echo ""
	    echo "          sh $TST_SHELL/runfe.sh init abf copy "
	    echo ""

	    exit 1
     else	
	    
        for fac in $*
        do
	    
	    if [ "$fac" = "all" -o "$fac" = "4gl" ]
	    then
               if [ ! -d $TST_OUTPUT/4gl ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/4gl"
                   echo ""
		   mkdir $TST_OUTPUT/4gl
		 fi

		echo "Initializing 4GL database @ ", `date`
                echo ""
		destroydb abf4gldb >>$TST_OUTPUT/feinit.out
		createdb abf4gldb >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database abf4gldb Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=abf4gldb
		export SEPPARAMDB

		sep -b $TST_INIT/init4gl.sep -o$TST_OUTPUT/4gl
	       
 	    fi

 	    if [ "$fac" = "all" -o "$fac" = "abf" ]
 	    then

               if [ ! -d $TST_OUTPUT/abf ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/abf"
                   echo ""
		   mkdir $TST_OUTPUT/abf
		 fi

		echo "Initializing ABF databases @ ", `date`
                echo ""
        	destroydb abfdb1 >>$TST_OUTPUT/feinit.out
        	createdb abfdb1 >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database abfdb1 Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=abfdb1
		export SEPPARAMDB

		sep -b $TST_INIT/initabf1.sep -o$TST_OUTPUT/abf

        	destroydb abfdb2 >>$TST_OUTPUT/feinit.out
        	createdb abfdb2 >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database abfdb2 Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB1=abfdb2
		export SEPPARAMDB1

		sep -b $TST_INIT/initabf2.sep -o$TST_OUTPUT/abf

 	    fi
	
	    if [ "$fac" = "all" -o "$fac" = "image" ]
	    then
		
               if [ ! -d $TST_OUTPUT/image ]
 	         then
		   echo "Creating Directory - $TST_OUTPUT/image"
                   echo ""
		   mkdir $TST_OUTPUT/image
		 fi

		echo "Initializing ImageApp database @ ", `date`
                echo ""
		destroydb imagedb >>$TST_OUTPUT/feinit.out
		createdb imagedb >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database imagedb Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		destroydb imagedb2 >>$TST_OUTPUT/feinit.out
		createdb imagedb2 >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database imagedb2 Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

	     fi

 	     if [ "$fac" = "all" -o "$fac" = "copy" ]
 	     then

               if [ ! -d $TST_OUTPUT/copy ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/copy"
                   echo ""
		   mkdir $TST_OUTPUT/copy
		 fi

		echo "Initializing COPY database @ ", `date`
                echo ""

#               Create database if not already created in ABF
#               INIT section

# 		Added destroydb copydb1.
# 		N.B. copydb1 is not created in ABF. 
                destroydb copydb1 >>$TST_OUTPUT/feinit.out
                createdb copydb1 >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database copydb1 Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=copydb1
		export SEPPARAMDB

		sep -b $TST_INIT/initcopy.sep -o$TST_OUTPUT/copy

 	     fi

	     if [ "$fac" = "all" -o "$fac" = "frs" ]
	     then

               if [ ! -d $TST_OUTPUT/frs ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/frs"
                   echo ""
		   mkdir $TST_OUTPUT/frs
		 fi

	        echo "Initializing FRS database @ ", `date`
                echo ""
	        destroydb frsdb >>$TST_OUTPUT/feinit.out
	        createdb frsdb >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database frsdb Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

	     fi

	     if [ "$fac" = "all" -o "$fac" = "fstm" ]
	     then

               if [ ! -d $TST_OUTPUT/fstm ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/fstm"
                   echo ""
		   mkdir $TST_OUTPUT/fstm
		 fi

	        echo "Initializing FSTM database @ ", `date`
                echo ""
                destroydb basisdb >>$TST_OUTPUT/feinit.out
		createdb basisdb >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database basisdb Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=basisdb
		export SEPPARAMDB
		
		sep -b $TST_INIT/initfstm.sep -o$TST_OUTPUT/fstm

	     fi
 			
 			
           if [ "$fac" = "all" -o "$fac" = "qbf" ]
             then
				
                if [ ! -d $TST_OUTPUT/qbf ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/qbf"
                   echo ""
		   mkdir $TST_OUTPUT/qbf
		 fi

		echo "Initializing QBF database @ ", `date`
                echo ""
	        destroydb qbf1 >>$TST_OUTPUT/feinit.out
	        createdb qbf1 >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database qbf1 Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=qbf1
		export SEPPARAMDB
		
		sep -b $TST_INIT/initqbf1.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf2.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf3.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf4.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf5.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf6.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf7.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf8.sep -o$TST_OUTPUT/qbf
		sep -b $TST_INIT/initqbf9.sep -o$TST_OUTPUT/qbf
	        	
	     fi

 	     if [ "$fac" = "all" -o "$fac" = "rbf" ]
 	     then

               if [ ! -d $TST_OUTPUT/rbf ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/rbf"
                   echo ""
		   mkdir $TST_OUTPUT/rbf
		 fi

		echo "Initializing RBF database's @ ", `date` 
               echo ""  
		destroydb rbfdb1 >>$TST_OUTPUT/feinit.out
		createdb rbfdb1 >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database rbfdb1 Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=rbfdb1
		export SEPPARAMDB

		sep -b $TST_INIT/initrbf.sep -o$TST_OUTPUT/rbf

 	     fi

 	     if [ "$fac" = "all" -o "$fac" = "rw" ]
 	     then

               if [ ! -d $TST_OUTPUT/rw ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/rw"
                  echo ""  
		   mkdir $TST_OUTPUT/rw
		 fi

		echo "Initializing REPORT WRITER database @ ", `date`
                echo ""
		destroydb rwdb >>$TST_OUTPUT/feinit.out
		createdb rwdb >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database rwdb Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=rwdb
		export SEPPARAMDB

		sep -b $TST_INIT/initrw.sep -o$TST_OUTPUT/rw
	     fi

             if [ "$fac" = "all" -o "$fac" = "vifred" ]
 	     then
               if [ ! -d $TST_OUTPUT/vifred ]
 		 then
		   echo "Creating Directory - $TST_OUTPUT/vifred"
                   echo ""
		   mkdir $TST_OUTPUT/vifred
		 fi

		echo "Initializing Vifred database @ ",`date`
                echo ""
		destroydb vifred1 >>$TST_OUTPUT/feinit.out
		createdb vifred1 >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database vifred1 Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=vifred1
		export SEPPARAMDB

		sep -b $TST_INIT/initvif.sep -o$TST_OUTPUT/vifred
	     fi

 	     if [ "$fac" = "all" -o "$fac" = "vision" ]
 	     then
               if [ ! -d $TST_OUTPUT/vision ]
		 then
		   echo "Creating Directory - $TST_OUTPUT/vision"
                   echo ""
		   mkdir $TST_OUTPUT/vision
		 fi

 		echo "Initializing Vision database @ ",`date`
                echo ""
		destroydb gourmet >>$TST_OUTPUT/feinit.out
		createdb gourmet >>$TST_OUTPUT/feinit.out

                if [ $? != 0 ]
                   then
                     echo Creation of Frontend database gourmet Failed.
                     echo See $TST_OUTPUT/feinit.out for error messages.
                   exit 1
                fi

		SEPPARAMDB=gourmet
		export SEPPARAMDB

		sep -b $TST_INIT/initvis.sep -o$TST_OUTPUT/vision
	     fi

	done 
#
     fi
#
	echo "Finished initializing databases @ ",`date`
fi

#
#------------------------------------------------------------------------------
#			End of Initialization Area
#------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------
#			Main Work Area
#------------------------------------------------------------------------------
#
if [ "$work" = "fe" ]
then
	for fac in $*
	do

		if [ "$fac" = "all" -o "$fac" = "4gl" ]
		then
#
# Run the 4GL tests
#
			SEPPARAMDB=abf4gldb
			export SEPPARAMDB
	
			echo "Running the 4GL tests @ ", `date` 
			echo ""
			qawtl RUNNING FE/4GL TESTS
			executor -t10 $TST_CFG/fe4gl.cfg >$TST_OUTPUT/4gl/fe4gl.out

			echo "Finished 4GL test @ ", `date`
			echo ""
			qawtl END FE/4GL TESTS
		fi

		if [ "$fac" = "all" -o "$fac" = "abf" ]
		then
#
# Run ABF tests
#
			SEPPARAMDB=abfdb1
			export SEPPARAMDB 
			SEPPARAMDB1=abfdb2
			export SEPPARAMDB1

			echo "Running the ABF tests @ ", `date` 
			echo ""
			qawtl RUNNING FE/ABF TESTS
			executor -t58 $TST_CFG/feabf.cfg >$TST_OUTPUT/abf/feabf.out

			echo "Finished ABF tests @ ", `date`
			echo ""
			qawtl END FE/ABF TESTS
		fi

		if [ "$fac" = "all" -o "$fac" = "image" ]
		then
#
# Run ABF image tests
#
			SEPPARAMDB=imagedb
			SEPPARAMDB1=imagedb2
			export SEPPARAMDB SEPPARAMDB1 

			echo "Running the IMAGE tests @ ", `date` 
			echo "all"
			qawtl RUNNING FE/IMAGE TESTS
			executor $TST_CFG/feimage.cfg >$TST_OUTPUT/image/feimage.out

			echo "Finished IMAGE tests @ ", `date`
			echo ""
			qawtl END FE/IMAGE TESTS
		fi

		if [ "$fac" = "all" -o "$fac" = "copy" ]
		then

#
# Run the COPY tests
#
			SEPPARAMDB=copydb1
			export SEPPARAMDB

			echo "Running the COPY tests @ ",`date` 
			echo ""
			qawtl RUNNING FE/COPY TESTS
			executor $TST_CFG/fecopy.cfg >$TST_OUTPUT/copy/fecopy.out

			echo Finished COPY tests @ `date`
			echo ""
			qawtl END FE/COPY TESTS
		fi

 		if [ "$fac" = "all" -o "$fac" = "fefutil" ]
 		then
# 
# Run the FORMUTIL tests
# 
                        if [ ! -d $TST_OUTPUT/fefutil ]
 		         then
 		           echo "Creating Directory - $TST_OUTPUT/fefutil"
                           echo ""
 		           mkdir $TST_OUTPUT/fefutil
 		         fi
 
                        destroydb -u'$ingres' ima_db
 			echo "Running the FORMUTIL tests @ ", `date` 
 			echo ""
			qawtl RUNNING FE/FORMUTIL TESTS
 			executor $TST_CFG/fefutil.cfg >$TST_OUTPUT/fefutil/fefutil.out
 			echo Finished the Formutil tests @ `date`
 			echo ""
			qawtl END FE/FORMUTIL TESTS
 		fi

		if [ "$fac" = "all" -o "$fac" = "frs" ]
		then
#
# Run the FRS tests
#
			SEPPARAMDB=frsdb
			export SEPPARAMDB

			if [ "$DIFF_SLEEP" ]
			then
			    diff_sleep_save=$DIFF_SLEEP
			    unset DIFF_SLEEP
			    export DIFF_SLEEP  
			fi

			echo "Running the FRS tests @ ",`date` 
			echo ""
			qawtl RUNNING FE/FRS TESTS
			executor $TST_CFG/fefrs.cfg >$TST_OUTPUT/frs/fefrs.out

			echo "Finished FRS tests @ ",`date`
			echo ""
			qawtl END FE/FRS TESTS

			if [ "$diff_sleep_save" ]
			then
			    DIFF_SLEEP=$diff_sleep_save
			    unset diff_sleep_save
			    export DIFF_SLEEP
			fi
		fi

		if [ "$fac" = "all" -o "$fac" = "fstm" ]
		then
#
# Run the FSTM tests
#
			SEPPARAMDB=basisdb
			export SEPPARAMDB
	
			echo "Running the FSTM tests @ ",`date` 
			echo ""
			qawtl RUNNING FE/FSTM TESTS
			executor $TST_CFG/fefstm.cfg >$TST_OUTPUT/fstm/fefstm.out

			echo "Finished FSTM tests @ ",`date`
			echo ""
			qawtl END FE/FSTM TESTS
		fi

		if [ "$fac" = "all" -o "$fac" = "qbf" ]
		then
#
# Run the QBF tests
#
			SEPPARAMDB=qbf1
			export SEPPARAMDB

			echo "Running the QBF tests @ ",`date`
			echo ""
			qawtl RUNNING FE/QBF TESTS
			executor $TST_CFG/feqbf.cfg >$TST_OUTPUT/qbf/feqbf.out

			echo "Finished QBF tests @ ",`date`
			echo ""
			qawtl END FE/QBF TESTS
		fi

		if [ "$fac" = "all" -o "$fac" = "rbf" ]
		then
#
# Run the RBF tests
#
			SEPPARAMDB=rbfdb1
			export SEPPARAMDB

			echo "Running the RBF tests @ ",`date` 
                        echo ""
			qawtl RUNNING FE/RBF TESTS
			executor $TST_CFG/ferbf.cfg >$TST_OUTPUT/rbf/ferbf.out

			echo "Finished RBF tests @ ",`date`
			echo ""
			qawtl END FE/RBF TESTS
		fi

		if [ "$fac" = "all" -o "$fac" = "rw" ]
		then
#
# Run the Report Writer tests
#
			SEPPARAMDB=rwdb
			export SEPPARAMDB

			echo "Running the REPORT WRITER tests @ ",`date` 
			echo ""
			qawtl RUNNING FE/RW TESTS
			executor $TST_CFG/ferw.cfg >$TST_OUTPUT/rw/ferw.out

			echo "Finished Report Writer tests @ ",`date`
			echo ""
			qawtl END FE/RW TESTS
		fi
	
		if [ "$fac" = "all" -o "$fac" = "vision" ]
		then
#
# Run the VISION tests
#
			SEPPARAMDB=gourmet
			export SEPPARAMDB

			if [ "$DIFF_SLEEP" ]
			then
			    diff_sleep_save=$DIFF_SLEEP
			    unset DIFF_SLEEP
			    export DIFF_SLEEP  
			fi

			echo "Running the VISION tests @ ",`date` 
                        echo ""  
			qawtl RUNNING FE/VISION TESTS
			executor $TST_CFG/fevis.cfg >$TST_OUTPUT/vision/fevis.out

			echo "Finished Vision tests @ ",`date`
			echo ""
			qawtl END FE/VISION TESTS

			if [ "$diff_sleep_save" ]
			then
			    DIFF_SLEEP=$diff_sleep_save
			    unset diff_sleep_save
			    export DIFF_SLEEP
			fi
		fi

		if [ "$fac" = "all" -o "$fac" = "vifred" ]
		then
#
# Run the VIFRED tests
#
			SEPPARAMDB=vifred1
			export SEPPARAMDB

			if [ "$DIFF_SLEEP" ]
			then
			    diff_sleep_save=$DIFF_SLEEP
			    unset DIFF_SLEEP
			    export DIFF_SLEEP  
			fi

			echo "Running the VIFRED tests @ ",`date`
                        echo ""
			qawtl RUNNING FE/VIFRED TESTS
			executor $TST_CFG/fevifred.cfg >$TST_OUTPUT/vifred/fevifred.out

			echo "Finished Vifred tests @ ",`date`
			echo ""
			qawtl END FE/VIFRED TESTS

			if [ "$diff_sleep_save" ]
			then
			    DIFF_SLEEP=$diff_sleep_save
			    unset diff_sleep_save
			    export DIFF_SLEEP
			fi
		fi

# Run the GENUTIL tests
#
                if [ "$fac" = "all" -o "$fac" = "genutil" ]
                then

                        if [ ! -d $TST_OUTPUT/genutil ]
 		          then
		            echo "Creating Directory - $TST_OUTPUT/genutil"
                            echo ""
		            mkdir $TST_OUTPUT/genutil
		          fi

			SEPPARAMDB=genutildb
			export SEPPARAMDB

			echo "Running the Genutil tests @ ",`date`
                        echo ""
			qawtl RUNNING FE/GENUTIL TESTS
		      executor $TST_CFG/fegenutil.cfg >$TST_OUTPUT/genutil/fegenutil.out

			echo "Finished Genutil tests @ ",`date`
			echo ""
			qawtl END FE/GENUTIL TESTS

                fi

# End of Front End Tests

 		echo "End of FE/SEP tests @ `date` . . . "
	done
fi
#-----------------------------------------------------------------------
#			Clean Up Area
#-----------------------------------------------------------------------
#
if [ "$work" = "clean" ]
then
    if [ "$*" = "" ]
    then
  	    echo "You must input the modules to be cleaned up "
	    echo "or specify ""all""."
	    echo ""
	    echo " Example: sh $TST_SHELL/runfe.sh clean all "
	    echo ""
	    echo "          or "
	    echo ""
	    echo "          sh $TST_SHELL/runfe.sh clean abf copy "
	    echo ""

	    exit 1
     else	
	    
        for fac in $*
        do
	    
	    if [ "$fac" = "all" -o "$fac" = "4gl" ]
	    then

		echo "Destroying 4GL database @ ", `date`
                echo ""
		destroydb abf4gldb >>$TST_OUTPUT/feclean.out

 	    fi

 	    if [ "$fac" = "all" -o "$fac" = "abf" ]
 	    then


		echo "Destroying ABF databases @ ", `date`
                echo ""
        	destroydb abfdb1 >>$TST_OUTPUT/feclean.out
        	destroydb abfdb2 >>$TST_OUTPUT/feclean.out

 	    fi
	
	    if [ "$fac" = "all" -o "$fac" = "image" ]
	    then
		

		echo "Destroying ImageApp database @ ", `date`
                echo ""
		destroydb imagedb >>$TST_OUTPUT/feclean.out
		destroydb imagedb2 >>$TST_OUTPUT/feclean.out

	     fi

 	     if [ "$fac" = "all" -o "$fac" = "copy" ]
 	     then


		echo "Destroying COPY database @ ", `date`
                echo ""
                destroydb copydb1 >>$TST_OUTPUT/feclean.out

 	     fi

	     if [ "$fac" = "all" -o "$fac" = "frs" ]
	     then


	        echo "Destroying FRS database @ ", `date`
                echo ""
	        destroydb frsdb >>$TST_OUTPUT/feclean.out

 	     fi


 	     if [ "$fac" = "all" -o "$fac" = "fstm" ]
 	     then
 
 
 	        echo "Destroying FSTM database @ ", `date`
                echo ""
		destroydb basisdb >>$TST_OUTPUT/feclean.out

 	     fi
 			
 			
             if [ "$fac" = "all" -o "$fac" = "qbf" ]
             then
				

		echo "Destroying QBF database @ ", `date`
                echo ""
	        destroydb qbf1 >>$TST_OUTPUT/feclean.out
	        	
	     fi

 	     if [ "$fac" = "all" -o "$fac" = "rbf" ]
 	     then


		echo "Destroying RBF database's @ ", `date` 
                echo ""  
		destroydb rbfdb1 >>$TST_OUTPUT/feclean.out

 	     fi

 	     if [ "$fac" = "all" -o "$fac" = "rw" ]
 	     then


		echo "Destroying REPORT WRITER database @ ", `date`
                echo ""  
		destroydb rwdb >>$TST_OUTPUT/feclean.out

	     fi

             if [ "$fac" = "all" -o "$fac" = "vifred" ]
 	     then

		echo "Destroying Vifred database @ ",`date`
                echo ""  
		destroydb vifred1 >>$TST_OUTPUT/feclean.out
	     fi

 	     if [ "$fac" = "all" -o "$fac" = "vision" ]
 	     then

 		echo "Destroying Vision database @ ",`date`
                echo ""  
		destroydb gourmet >>$TST_OUTPUT/feclean.out

	     fi

 	     if [ "$fac" = "all" -o "$fac" = "genutil" ]
 	     then

 		echo "Destroying GENUTIL database @ ",`date`
                echo ""  
		destroydb genutildb >>$TST_OUTPUT/feclean.out

	     fi

	done 
#
     fi
#
	echo "Finished destroying databases @ ",`date`
fi
#
#----------------------------------------------------------------------
#			End of Clean Up Area
#----------------------------------------------------------------------
