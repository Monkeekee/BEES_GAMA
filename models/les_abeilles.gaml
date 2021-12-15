/**
* Name: lesabeilles
* Based on the internal empty template. 
* Author: matt
* Tags: 
*/


model lesabeilles

/* commencer avec seulement des abeilles corporate  */
/* 2 ou trois parametres au départ */
/* Insert your model definition here */

species flower {
	image_file icon <- image_file("../images/flower.png") ;
	int qtt_pollen <- 300 min: 0;
	aspect cercle {
		draw circle(30) color: #blue border: #black;
		draw string(qtt_pollen) color: #white size: 2; 
	}
	aspect icon {
		draw icon size: 100;
		draw string(qtt_pollen) color: #white size: 2; 
	}
	reflex when: qtt_pollen = 0{
		do die;
	}
}

species pelouse {
	
}

species bees skills: [moving]{
	int timer_dance <- 0;
	bool dance_au_retour <-false;
	bool lone_bee <- false;
	point bonplan <- nil;
	point destiDanse <- nil;
	bool satisfied <- false;
	float moving_cost <-0.1;
	float energie <- rnd(500.0,1000.0) min: 0.0 update: energie - moving_cost;
	int max_pollen <- 3 max: 50;
	int charge_pollen <- 0 min: 0 max: max_pollen;
	image_file icon <- image_file("../images/bee.png") ;
	
	aspect cercle {
		if(self.lone_bee) { draw circle(6) color: #red border: #black;} 
        else {draw circle(5) color: #yellow border: #black;}
	}
	aspect icon {
		draw icon size: 50;
	}
	
	list<flower> flower_at_sight <- flower at_distance dist_percep update: flower at_distance dist_percep;
	
	flower fp <- flower at_distance dist_percep closest_to self update: flower at_distance dist_percep closest_to self;
	
	list<bees> bees_at_sight <- bees at_distance dist_percep update: bees at_distance dist_percep;
	
	list<bees> voisine_dansantes <- bees_at_sight where (bonplan != nil);

	reflex basic_move when: charge_pollen < max_pollen and energie > seuil_energie{
		
		if (destiDanse != nil){
			do goto target: (destiDanse);
		}
		
		
			
			
		
		else {
			if ( !empty(flower_at_sight) and charge_pollen != max_pollen){
				do goto target: fp;
			}
			else{
				if !empty(voisine_dansantes) {
				destiDanse <- (voisine_dansantes closest_to self).bonplan;
				}
				do wander amplitude: 30.0;
			}
		}
	}
	reflex buttine when: fp != nil and charge_pollen < max_pollen and (flower_at_sight at_distance 0.5) {
		fp.qtt_pollen <- fp.qtt_pollen-1;

		charge_pollen <- charge_pollen + 1;
		
		if (fp.qtt_pollen > 270) {
			dance_au_retour <- true;
			if (fp != nil ){
			bonplan <-fp.location;
			}	
		}
	}
	
	reflex rentrer when: (charge_pollen = max_pollen or energie < seuil_energie) {
			ruche r <- ruche[0];
			//point previous <- fp.location;
			//int charge_fp <- fp.qtt_pollen;
				
			do goto target: r;
			
			if !empty(ruche at_distance 0.5) {
				if (dance_au_retour){
					timer_dance <- timer_dance +1;
					location <- middle;
					if (timer_dance = 1000){
						dance_au_retour <- false;
						timer_dance <- 0;
						bonplan <- nil;
					}
				}
				
				else {
						r.qtt_pollen <- r.qtt_pollen + charge_pollen; //deposer le pollen apres avoir dansé
						charge_pollen <- 0;
						
						
					if (r.qtt_miel > 0 and energie < seuil_energie){ //prendre du miel pour energie
						r.qtt_miel <- r.qtt_miel - 1;
						energie <- energie + qtt_energie_miel;
	
					}
				
				
				}
				
			
				
			}	
	}
	reflex dance when: dance_au_retour{
		
			//do wander amplitude:0.01 speed: 0.01;
			


	}
	reflex mourir when: energie = 0{
		do die;
	}	
	
		
	    
	
	
	init {
		
	}

}




species ruche {
	int required_pollen_to_honey <- 6;
	int qtt_miel <- 10 min:0 ;
	int qtt_pollen;
	image_file icon <- image_file("../images/ruche.png") ;
	
	aspect carre {
		draw square(100) color: #brown;
		draw string(qtt_miel) color: #white;
	}
	
	aspect joli {
		draw icon size: 200;
		draw string(qtt_miel) color: #black;
	}
	init{
		location <- middle;
	}
	
	reflex transfo_miel when: qtt_pollen > required_pollen_to_honey{
		qtt_miel <- qtt_miel + 1;
		qtt_pollen <- qtt_pollen - required_pollen_to_honey;
	}
}

species apiculteur {

}



global {
	
	
	int seuil_energie <- 200;
	int qtt_energie_miel <- 500;
	int nb_flower_init <- 10;
	geometry shape <- square(1000#m); //changer la taille de la simulation, 100x100 de base
	point middle <- {500,500};
	float dist_percep <- 100.0; //p*
	bool is_gui <- true;
	int nb_cycle_f <- 0 update: cycle;
	
	int nb_bees_friendly <- 20; //p*
	float neighboors_dist <- 5 #m; 

	
	init {
		
		create ruche;
		create flower number: nb_flower_init {
			//set location <-{rnd(-1,1,2)*rnd (0,500),rnd(-1,1,2)*rnd (0,500)};
			if ((myself.location.x - 500)^2 + (myself.location.y - 500)^2 < 100){
				set location <- myself.location + {rnd(-1,1,2)*rnd (100,500),rnd(-1,1,2)*rnd (100,500)}; //+ {300.0,300.0};
			}
}
			
		
 	
		create bees number: nb_bees_friendly;
		
		

		create apiculteur;
		/* je crée 2000 people à l'init du monde */
		/* create a une facette number pour le nombre de people a creer */
	}
	reflex arret when: (is_gui and nb_bees_friendly = 0) {
		do pause; //do sert à appeler des action predef comme pause, die, etc ou on peut les definir : action xxx
	}
	//is batch
	
	
	
}
experiment exp1 type: gui {
	//inputs : params
	//outputs : affichage, displays
	//image_file background <- image_file("../images/pelouse.png") ;
	parameter "energie obtenue par le miel" var: qtt_energie_miel category:"Bees";
	parameter "distance de perception des abeilles" var: dist_percep category: "Bees" ;
	parameter "nb abeilles" var: nb_bees_friendly category: "Bees" ;
	parameter "nombre de fleurs" var: nb_flower_init category: "Flowers" ;	

	output {
		display map background: #lightgreen{
	
			species ruche aspect: joli;
			species flower aspect: icon;
			species bees aspect: icon;
			
			//pas oublier l'aspect
		}
		monitor "Nb bees alive" value: length(bees); //fenetre non display, cas particulier
		monitor "Qtt de pollen dans les fleurs" value: sum (flower collect each.qtt_pollen);
		monitor "Qtt de pollen à la ruche" value: sum (ruche collect each.qtt_pollen);
		monitor "charge moyenne" value: mean (bees collect (each.charge_pollen));
		monitor "energie moyenne" value: mean (bees collect (each.energie));
	
		//display Comparion {
		//	chart "nb cycle " type: series{
		//		data "energie moyenne" value: mean (bees collect (each.energie));
		//	
		//	}
		//}

		
	}
	
	
}