require "./generic_ga/*"
require "random"

# TODO: Write documentation for `GenericGA`
module GenericGA
  alias Gene = Bool
  alias Chromosome = Array(Gene)
  alias Fitness = Int32
  # The number of genes in each chromosome
  GENE_COUNT = 20
  # Mutation chance
  MUTATION_CHANCE = 0.01

  random = Random.new

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
    end

    # Gets the fitness of the agent with the max fitness in the population.
    def max_fitness : Fitness
      @fitnesses.max
    end

    # Picks two agents (weighted by fitness) from the population
    # to reproduce, yielding two new agents that replace them
    def selection : Nil
      # pick parents (the top two agents)
      max = self.max_fitness
      second_max = 0
      p1 = nil # first max agent
      p2 = nil # second max agent
      i = 0
      @size.times do |i|
        f = @population[i].fitness
        if f == max
          p1 = i
        elsif f > second_max
          p2 = i
          second_max = f
        end
      end

      # reproduce
      case p1
      when Int32
        case p2
        when Int32
          # puts "parents: #{@population[p1].dna}, #{@population[p2].dna}"
          crossover p1, p2
        end
      end
    end

    def update_fitness(i : Int32) : Nil
      @fitnesses[i] = @population[i].fitness
    end

    # Exchanges some genes between two agents's chromosomes
    def crossover(p1, p2 : Int32) : Nil
      a, b = @population[p1], @population[p2]
      # choose random pivot
      pivot = Random.new.rand GENE_COUNT
      pivot.times do |gene|
        # trade gene i, with chance of mutation
        tmp = a.chromosome[gene]
        a.chromosome[gene] = mutate b.chromosome[gene]
        b.chromosome[gene] = mutate tmp
      end
      # chance to mutate rest of genes as well
      (GENE_COUNT - pivot).times do |i|
        gene = i + pivot
        a.chromosome[gene] = mutate a.chromosome[gene]
        b.chromosome[gene] = mutate b.chromosome[gene]
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
