require "./generic_ga/*"
require "random"

# TODO: Write documentation for `GenericGA`
module GenericGA
  alias Gene = Bool
  alias Chromosome = Array(Gene)
  alias Fitness = Int32
  GENE_COUNT      = 100
  MUTATION_CHANCE = 0.1
  INHERIT_CHANCE  = 0.5

  # Creates a random gene value.
  def make_random_gene : Gene
    Random.new.next_bool
  end

  # Mutates a gene
  def mutate_gene(g : Gene) : Gene
    !g
  end

  # Creates an empty chromosome (initialized array).
  def make_chromosome : Chromosome
    Chromosome.new GENE_COUNT
  end

  # Creates a chromosome filled with random gene values.
  def make_random_chromosome : Chromosome
    Chromosome.new(GENE_COUNT) { make_random_gene }
  end

  def bool_to_int(b : Bool) : Int32
    return 1 if b
    return 0
  end

  # Calculates the fitness of a given chromosome.
  def fitness_function(chromosome : Chromosome) : Fitness
    f = 0
    chromosome.map { |gene| f += bool_to_int gene }
    return f
  end

  # An agent in the simulation. Has a chromosome and some useful functions.
  struct Agent
    include GenericGA
    property chromosome : Chromosome

    def initialize(randomize = false)
      if randomize
        @chromosome = make_random_chromosome
      else
        @chromosome = make_chromosome
      end
    end

    # Calculates agent's fitness
    def fitness : Fitness
      fitness_function @chromosome
    end

    def dna : Array(Int32)
      @chromosome.map { |gene| bool_to_int gene }
    end
  end

  struct World
    include GenericGA
    getter population
    getter fitnesses
    getter size

    # Initialized population with random agents, and an array to keep track of their fitnesses.
    def initialize(@size : Int32)
      @population = Array(Agent).new(size) { Agent.new true }
      @fitnesses = Array(Fitness).new(@size) { |i| @population[i].fitness }
    end

    def simulate(steps : Int32)
      steps.times do |i|
        puts "[Generation #{i}] Max Fitness: #{self.max_fitness}"
        selection
      end
      puts "--------------------------------------"
      puts "Grand Max Fitness: #{self.max_fitness}"
      puts "Winning Genes:     #{self.max_agent.dna}"
    end

    # Gets the fitness of the agent with the max fitness in the population.
    def max_fitness : Fitness
      @fitnesses.max
    end

    def max_agent : Agent
      max = @population[0]
      @population.map { |agent|
        if agent.fitness > max.fitness
          max = agent
        end
      }
      max
    end

    def choose_parents : Tuple(Int32, Int32)
      total_fitness = @fitnesses.sum
      min_fitness = @fitnesses.min
      random = Random.new

      fitness_indecies = Array.new(@size) { |i| 0 }
      i = 0
      @fitnesses.map { |f|
        total_fitness += f
        fitness_indecies[i] = total_fitness
        i += 1
      }

      # parent 1
      choice1 = random.rand total_fitness
      p1 = 0
      i = 0
      fitness_indecies.map { |f|
        if f < choice1
          p1 = i
        end
        i += 1
      }

      # parent 2
      choice2 = random.rand total_fitness
      while (choice2 - choice1).abs < min_fitness
        choice2 = random.rand total_fitness
      end
      p2 = 0
      i = 0
      fitness_indecies.map { |f|
        if f < choice2
          p2 = i
        end
        i += 1
      }

      return p1, p2
    end

    # Picks two agents (weighted by fitness) from the population
    # to reproduce, yielding two new agents that replace them
    def selection : Nil
      # parents
      p1, p2 = choose_parents
      # crossover
      crossover p1, p2
    end

    def update_fitness(i : Int32) : Nil
      @fitnesses[i] = @population[i].fitness
    end

    # Exchanges some genes between two agents's chromosomes
    def crossover(p1, p2 : Int32) : Nil
      a, b = @population[p1], @population[p2]
      random = Random.new

      GENE_COUNT.times do |gene|
        # trade half of genes (on average)
        if random.rand < INHERIT_CHANCE
          tmp = a.chromosome[gene]
          a.chromosome[gene] = mutate b.chromosome[gene]
          b.chromosome[gene] = mutate tmp
        end
      end

      # update fitnesses
      update_fitness p1
      update_fitness p2

      # puts "children: #{@population[p1].dna}, #{@population[p2].dna}"
    end

    # Chance of mutating a gene.
    def mutate(g : Gene) : Gene
      if Random.new.rand < MUTATION_CHANCE
        return mutate_gene g
      else
        return g
      end
    end
  end
end
