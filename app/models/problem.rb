class Problem < ActiveRecord::Base
  LEVELS = [1, 2, 4, 8]
  PRICES = { 
    1 => 5, 
    2 => 10, 
    4 => 25, 
    8 => 50 }
  belongs_to :contest
  belongs_to :user

  has_many :solutions
  has_many :tests, :class_name => 'ProblemTest',
           :order => 'hidden DESC, id ASC',
           :dependent => :destroy
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy,
           :order => 'created_at DESC'
  has_many :users, :through => :solutions, :uniq => true

  validates_presence_of :name, :text
  validates_inclusion_of :level, :in => LEVELS

  named_scope :commented, :conditions => ["comments_count > 0 and active_from < ?", Time.now]
  named_scope :active, :conditions => ["active_from < ?", Time.now]

  before_save :copy_times

  after_save :notify_user
  
  def active?
    self.active_from && (self.active_from < Time.now)
  end

  def publicized?
    contest && contest.started?
  end

  def correct_solutions
    solutions.passed
  end

  def corrects_count
    correct_solutions.count
  end

  def solutions_count
    solutions.count
  end

  define_index do
    indexes :name
    indexes :text
    indexes :source
    set_property :field_weights => { 
      :name => 10,
      :text => 6,
      :source => 3
    }
    set_property :delta => true
  end

  def check!
    unless self.tests.real.empty?
      self.solutions.each { |solution| solution.check! }
    end
  end

  def self.resum_counts!
    all.each do |problem|
      problem.tried_count = problem.solutions_count
      problem.solved_count = problem.corrects_count
      problem.save!
    end
  end

  private
  def copy_times
    if changes.has_key?('contest_id') && contest
      self.active_from = contest.start
      self.inactive_from = contest.end
    end
  end

  def notify_user
    if self.changes['contest_id']
      user.deliver_problem_selection!(contest, self)
    end
  end
end
