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
	int qtt_pollen <- reserve_max min: 0;
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
	
	
	int duree_danse <- rnd(300,500);
	int timer_dance <- 0;
	bool lone_bee <- false;
	flower bonplan <- nil;
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
	int nb_voisines <- length(bees_at_sight) update: length(bees_at_sight);
	
	list<bees> voisine_dansantes <- bees_at_sight where (each.timer_dance >0 ) update: bees_at_sight where (each.timer_dance >0);
	int nb_vd <-  length(voisine_dansantes) update: length(voisine_dansantes);

	

	reflex basic_move when: charge_pollen < max_pollen and energie > seuil_energie {
		
		//si j'ai une voisine qui danse je recup son plan
		if (!empty(voisine_dansantes) and self.bonplan = nil) {
				self.bonplan <- voisine_dansantes[0].bonplan;
			}
		
		if ( !empty(flower_at_sight) ){ //je vais a une fleur dans mon champs de vison
			self.bonplan <- nil;
			do goto target: fp;
		}
		else{
			do wander amplitude: 30.0;
		}
		
		if (self.bonplan != nil) {
			do goto target: self.bonplan;
		}
		
	}
	reflex buttine when: fp != nil and charge_pollen < max_pollen and (flower_at_sight at_distance 0.5) { //je buttine la fleur su laquelle je suis

		fp.qtt_pollen <- fp.qtt_pollen-1;

		charge_pollen <- charge_pollen + 1;

		if (fp.qtt_pollen > prop_bonplan * reserve_max) { //bonplan detecté
			bonplan <-fp;
			timer_dance <- duree_danse;
		}
		else {bonplan <- nil;
		}
	}
	
	reflex rentrer when: (charge_pollen = max_pollen or energie < seuil_energie) {

			ruche r <- ruche[0];
				
			do goto target: r; //aller à la ruche
			
			if !empty(ruche at_distance 0.5) { //des que je suis proche de la ruche en y rentrant
				if (timer_dance > 0){
					timer_dance <- timer_dance - 1;
					location <- middle;
					if (timer_dance = 0){
							self.bonplan <- nil;
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

	reflex mourir when: energie = 0{
		do die;
	}	
	
}




species ruche {
	int revenu <- 0;
	int required_pollen_to_honey <- 6;
	int chrono <- 0 update: chrono +1;
	int qtt_miel <- 10 min:0 ;
	int qtt_pollen;
	image_file icon <- image_file("../images/ruche.png") ;
	
	aspect carre { //aspect qui consomme le moins de CPU
		draw square(100) color: #lightgrey;
		draw string("Miel") color: #black at: self.location + {100.0,10.0};
		draw string(qtt_miel) color: #black at: self.location + {100.0,30.0};
		draw string("Revenu") color: #darkgreen at: self.location + {100.0,50.0};
		draw string(revenu) color: #darkgreen at: self.location + {100.0,70.0};
	}
	
	aspect joli {
		draw icon size: 200;
		draw string("Miel") color: #black at: self.location + {100.0,10.0};
		draw string(qtt_miel) color: #black at: self.location + {100.0,30.0};
		draw string("Revenu") color: #darkgreen at: self.location + {100.0,50.0};
		draw string(revenu) color: #darkgreen at: self.location + {100.0,70.0};
		draw string("Timer") color: #brown at: self.location + {100.0,90.0};
		draw string(chrono) color: #brown at: self.location + {100.0,110.0};
		
	}
	init{
		location <- middle;
	}
	
	
	reflex transfo_argent when: chrono = recolte_every{
		if (qtt_miel > seuil_recolte){
			revenu <- revenu + qtt_miel-seuil_recolte;
			qtt_miel <- seuil_recolte;
		}
		chrono <- 0;
		
	}
	
	reflex transfo_miel when: qtt_pollen > required_pollen_to_honey{
		qtt_miel <- qtt_miel + 1;
		qtt_pollen <- qtt_pollen - required_pollen_to_honey;
	}
}





global {
	float prop_bonplan <- 0.8;
	int seuil_recolte <- 10;
	int recolte_every <- 4000;
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
	int reserve_max <- 300 min: 300;
	
	init {
		
		create ruche;
		create flower number: nb_flower_init {
			//set location <-{rnd(-1,1,2)*rnd (0,500),rnd(-1,1,2)*rnd (0,500)};
			if ((myself.location.x - 500)^2 + (myself.location.y - 500)^2 < 100){
				set location <- myself.location + {rnd(-1,1,2)*rnd (100,500),rnd(-1,1,2)*rnd (100,500)}; //+ {300.0,300.0};
			}
}
			
		
 	
		create bees number: nb_bees_friendly;
		
	}
	reflex arret when: (is_gui and length(bees) = 0) {
		do pause; 
	}
	
	
}
experiment GUI type: gui {

	//inputs : params
	//outputs : affichage, displays

	parameter "L'apiculteur recolte le miel tous les :" var: recolte_every among: [500, 1000, 1500, 2000, 4000, 8000] category:"Ruche";
	parameter "Miel laissé par récolte :" var: seuil_recolte among: [0, 10, 15, 30] category:"Ruche";
	parameter "Energie obtenue par le miel :" var: qtt_energie_miel category:"Abeilles" among: [400, 500, 700, 1000];
	parameter "Distance de perception des abeilles :" var: dist_percep category: "Abeilles" min: 50.0 max: 300.0;
	parameter "Nombre d'abeilles :" var: nb_bees_friendly category: "Abeilles" min:5 max: 30;
	parameter "Nombre de fleurs :" var: nb_flower_init category: "Fleurs" among: [5,10,20,40];
	parameter "Proportion de remplissage pour avoir un bon plan" var: prop_bonplan category: "Abeilles" min: 0.5 max: 0.9 step: 0.05;

	output {
		display map background: #lightgreen{
	
			species ruche aspect: joli;
			species flower aspect: icon;
			species bees aspect: icon;

		}
		monitor "Nombre d'abeilles en vie" value: length(bees) refresh: every(100 #cycles); //fenetre non display, cas particulier
		monitor "Qtt de pollen dans les fleurs" value: sum (flower collect each.qtt_pollen) refresh: every(1000 #cycles) ;
		monitor "Charge de pollen moyenne par abeille" value: mean (bees collect (each.charge_pollen)) refresh: every(1000 #cycles);
		monitor "Energie moyenne des abeilles" value: mean (bees collect (each.energie)) refresh: every(1000 #cycles);
	}
}

experiment GUI_low_cpu type: gui {

	parameter "L'apiculteur recolte le miel tous les :" var: recolte_every among: [500, 1000, 1500, 2000, 4000, 8000] category:"Ruche";
	parameter "Miel laissé par récolte :" var: seuil_recolte among: [0, 10, 15, 30] category:"Ruche";
	parameter "Energie obtenue par le miel :" var: qtt_energie_miel category:"Abeilles" among: [400, 500, 700, 1000];
	parameter "Distance de perception des abeilles :" var: dist_percep category: "Abeilles" min: 50.0 max: 300.0;
	parameter "Nombre d'abeilles :" var: nb_bees_friendly category: "Abeilles" min:5 max: 30;
	parameter "Nombre de fleurs :" var: nb_flower_init category: "Fleurs" among: [5,10,20,40];
	parameter "Proportion de remplissage pour avoir un bon filon" var: prop_bonplan category: "Abeilles" min: 0.5 max: 0.9 step: 0.05;

	output {
		display map background: #lightgreen{
	
			species ruche aspect: carre;
			species flower aspect: cercle;
			species bees aspect: cercle;
			
			//pas oublier l'aspect
		}
		monitor "Nombre d'abeilles en vie" value: length(bees) refresh: every(100 #cycles); //fenetre non display, cas particulier
	}
}


experiment BATCH type: batch repeat:2 until: (length(bees)=nb_bees_friendly-1){ //s'arrete quand la premiere abeille meurt
	parameter "L'apiculteur recolte le miel tous les :" var: recolte_every among: [500, 1500, 4000] category:"Ruche";
	parameter "Miel laissé par récolte :" var: seuil_recolte among: [0, 10] category:"Ruche";

	method exhaustive maximize: ruche[0].revenu;
	permanent {
		display revenus {
			chart "Maximiser les revenus de l'apiculteur" type: series{
				data "Revenus moyens" value: simulations mean_of(each.ruche[0].revenu);
				data "Revenus Max" value: simulations max_of(each.ruche[0].revenu);
				data "Revenus min" value: simulations min_of(each.ruche[0].revenu);
			}
		}

	}
}

experiment BATCH2 type: batch repeat:2 until: (length(bees)=nb_bees_friendly-1){ //s'arrete quand la premiere abeille meurt
	parameter "L'apiculteur recolte le miel tous les :" var: recolte_every among: [500, 1500, 4000] category:"Ruche";
	parameter "Miel laissé par récolte :" var: seuil_recolte among: [0, 10] category:"Ruche";

	method exhaustive maximize: nb_cycle_f;
	
	permanent {
		display duree_de_vie {
			chart "Maximiser la durée de vie de toutes les abeilles" type: series{
				data "Cycle final moyen" value: simulations mean_of(each.nb_cycle_f);
				data "Cycle final Max" value: simulations max_of(each.nb_cycle_f);
				data "Cycle final min" value: simulations min_of(each.nb_cycle_f);
			}
		
		}

	}
}

experiment BATCH3 type: batch repeat:2 until: (ruche[0].revenu > 100 or length(bees)=nb_bees_friendly-1){ //s'arrete quand la premiere abeille meurt ou que les revenus sont hauts
	parameter "Proportion de remplissage pour avoir un bon filon" var: prop_bonplan category: "Abeilles" min: 0.5 max: 0.9 step: 0.10;
	parameter "Nombre de fleurs :" var: nb_flower_init category: "Fleurs" among: [40,20,10];

	method hill_climbing minimize: nb_cycle_f;
	//optimum local
	permanent {
		display D {
			chart "Minimiser le moment où on atteint 100 de revenu" type: series{
				data "Cycle final moyen" value: simulations mean_of(each.nb_cycle_f);
				data "Cycle final Max" value: simulations max_of(each.nb_cycle_f);
				data "Cycle final min" value: simulations min_of(each.nb_cycle_f);
			}
		
		}

	}

}





