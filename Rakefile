namespace :hg do
  
  desc "Pull and update this repository. May fail if you need to merge."
  task :pull_update do
    system %{hg pull http://hg.microformats.org/x2v/}
    system %{hg update}
  end
  
  desc "Pushes this repository to microformats.org. Pulls and updates first."
  task :push => :pull_merge do
    system %{hg push ssh://mercurial@microformats.org/repos/x2v}
  end
  
end