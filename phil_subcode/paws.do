

** paws_clean_prep.do
use "${pawsdata}full_sample.dta", clear
		
		** CLEAN CONACCT
			drop if conacct==.

		** AGE
			drop age
			destring age_extra, replace force ignore(+)
			ren age_extra age
			replace age=19 if age==198
			replace age=23 if age==230
			replace age=56 if age==564
			replace age=age*10 if age<=12
			replace age=100 if age>100 & age<.
			replace age=18 if age<18
				
		** HOUSE
			g house_1=regexm(house,"Apartment :")==1
			g house_2=regexm(house,"Single house")==1
		
		** INCOME
			g low_skill=job=="1"
			destring hhemp, replace force
				replace hhemp=8 if hhemp>8
					
		** HHSIZE AND SHARING MEASURES
			destring shr_hh_extra shr_num_extra hhsize, replace force
			replace hhsize=12 if hhsize>12
			g SHO=shr_num_extra - hhsize
			replace SHO=. if SHO<0
			g SHH=shr_hh_extra

			replace SHH=1 if wave==4 & SHH==.	
			*drop if SHO>15 & SHO<.  // CLEAN SHARING VARIABLES
			*drop if SHH>=4  & SHH<. 
			drop if SHO==.
			replace SHO=0 if SHH==1
			replace SHH=1 if wave==3 & SHO==0
			replace SHH=2 if wave==3 & SHO>0 & SHO<=6
			replace SHH=3 if wave==3 & SHO>6 & SHO<.
			* drop if SHH==2 & SHO<=1
			drop if SHH==3 & SHO<=2
		
		** KEY SHARING CUTOFF HERE
			replace SHO=30 if SHO>30
			replace SHH=3 if SHH>3
		
		keep conacct barangay_id wave $paws_vars
		order conacct barangay_id wave $paws_vars
		* house_1 house_2 age hhemp hhsize low_skill SHH SHO

odbc exec("DROP TABLE IF EXISTS paws;"), dsn("phil")
odbc insert, table("paws") dsn("phil") create
odbc exec("CREATE INDEX paws_conacct_ind ON paws (conacct);"), dsn("phil")




