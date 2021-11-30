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
	int qtt_pollen <- 300;
	aspect cercle {
		draw circle(30) color: #blue border: #black;
	}
}

species pelouse {
	
}

species bees skills: [moving]{
	bool lone_bee <- false;
	bool satisfied <- false;
	int pollen_charge <- 0;
	
	aspect cercle {
		if(self.lone_bee) { draw circle(6) color: #red border: #black;} 
        else {draw circle(5) color: #yellow border: #black;}
	}
	
	reflex basic_move {
		//do goto target: any_location_in(world.shape);
	    do wander;
	}
	reflex move_to_flower when: cycle > 500{
			do goto target: (one_of(flower));
		
	}
	
	init {
		
	}

}
species ruche {
	
	aspect carre {
		draw square(100) color: #brown;
	}
	init{
		location <- middle;
	}
}

species apiculteur {

}



global {
	int nb_flower_init <- 10;
	geometry shape <- square(1000#m); //changer la taille de la simulation, 100x100 de base
	point middle <- {500,500};
	float dist_percep <- 50.0; //p*
	bool is_gui <- true;
	int nb_cycle_f <- 0 update: cycle;
	
	int nb_bees_friendly <- 200; //p*
	float neighboors_dist <- 5 #m; 

	
	init {
		create flower number: nb_flower_init;
		create bees number: nb_bees_friendly;
		create ruche;
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


	
	output {
		display map {
			species bees aspect: cercle;
			species ruche aspect: carre;
			species flower aspect: cercle;
			//pas oublier l'aspect
		}
		monitor "Nb happy " value: nb_bees_friendly; //fenetre non display, cas particulier

		
	}
	
	
}