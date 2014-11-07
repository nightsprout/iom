# -*- coding: utf-8 -*-

# Mandatory seeds

User.find_or_create_by_email(
  :email                  => 'admin@example.com', 
  :name                   => "Admin",
  :password               => 'admin', 
  :password_confirmation  => 'admin', 
  :role                   => "admin"
)



settings = Settings.find_or_create_by_id(1)
data = HashWithIndifferentAccess.new
data[:main_site_host] = 'iom.dev'
data[:main_site_host] = 'partnersmap.org' if Rails.env.production?
settings.data = data
settings.save!


Theme.find_or_create_by_name :name => 'Garnet',
             :css_file => '/stylesheets/themes/garnet.css',
             :thumbnail_path => '/images/themes/1/thumbnail.png',
             :data => {
               :overview_map_chco => "F7F7F7,8BC856,336600",
               :overview_map_chf => "bg,s,2F84A3",
               :overview_map_marker_source => "/images/themes/1/",
               :georegion_map_chco => "F7F7F7,8BC856,336600",
               :georegion_map_chf => "bg,s,2F84A3",
               :georegion_map_marker_source => "/images/themes/1/",
               :georegion_map_stroke_color => "#000000",
               :georegion_map_fill_color => "#000000"
             }

Theme.find_or_create_by_name :name => 'Pink',
             :css_file => '/stylesheets/themes/pink.css',
             :thumbnail_path => '/images/themes/2/thumbnail.png',
             :data => {
               :overview_map_chco => "F7F7F7,8BC856,336600",
               :overview_map_chf => "bg,s,2F84A3",
               :overview_map_marker_source => "/images/themes/2/",
               :georegion_map_chco => "F7F7F7,8BC856,336600",
               :georegion_map_chf => "bg,s,2F84A3",
               :georegion_map_marker_source => "/images/themes/2/",
               :georegion_map_stroke_color => "#000000",
               :georegion_map_fill_color => "#000000"
             }

Theme.find_or_create_by_name :name => 'Blue',
             :css_file => '/stylesheets/themes/blue.css',
             :thumbnail_path => '/images/themes/3/thumbnail.png',
             :data => {
               :overview_map_chco => "F7F7F7,8BC856,336600",
               :overview_map_chf => "bg,s,2F84A3",
               :overview_map_marker_source => "/images/themes/3/",
               :georegion_map_chco => "F7F7F7,8BC856,336600",
               :georegion_map_chf => "bg,s,2F84A3",
               :georegion_map_marker_source => "/images/themes/3/",
               :georegion_map_stroke_color => "#000000",
               :georegion_map_fill_color => "#000000"
             }

# Env seeds (development)

Cluster.find_or_create_by_name :name => 'Camp Coordination and Management'
Cluster.find_or_create_by_name :name => 'Early Recovery'
Cluster.find_or_create_by_name :name => 'Education'
Cluster.find_or_create_by_name :name => 'Emergency Telecommunications'
Cluster.find_or_create_by_name :name => 'Food Security and Agriculture'
Cluster.find_or_create_by_name :name => 'Health'
Cluster.find_or_create_by_name :name => 'Logistics'
Cluster.find_or_create_by_name :name => 'Nutrition'
Cluster.find_or_create_by_name :name => 'Protection'
Cluster.find_or_create_by_name :name => 'Shelter and Non-Food Items'
Cluster.find_or_create_by_name :name => 'Water Sanitation and Hygiene'

Sector.find_or_create_by_name :name => 'Agriculture'
Sector.find_or_create_by_name :name => 'Communications'
Sector.find_or_create_by_name :name => 'Disaster Management'
Sector.find_or_create_by_name :name => 'Economic Recovery and Development'
Sector.find_or_create_by_name :name => 'Education'
Sector.find_or_create_by_name :name => 'Environment'
Sector.find_or_create_by_name :name => 'Food Aid'
Sector.find_or_create_by_name :name => 'Health'
Sector.find_or_create_by_name :name => 'Human Rights Democracy and Governance'
Sector.find_or_create_by_name :name => 'Peace and Security'
Sector.find_or_create_by_name :name => 'Protection'
Sector.find_or_create_by_name :name => 'Shelter and Housing'
Sector.find_or_create_by_name :name => 'Water Sanitation and Hygiene'
Sector.find_or_create_by_name :name => 'Other'

Tag.find_or_create_by_name :name => 'asia'
Tag.find_or_create_by_name :name => 'africa'
Tag.find_or_create_by_name :name => 'childhood'
Tag.find_or_create_by_name :name => 'earthquake'

##


####################################################################
#
# HAITI SITE
#
####################################################################

#  sites for testing purposes. Add this line to your /etc/hosts:
#  127.0.0.1       haiti.ngoaidmap.org
site = Site.find_or_initialize_by_name('Haiti Aid Map')

site.update_attributes(
  :name              => 'Haiti Aid Map',
  :url               => 'haiti.ngoaidmap.org',
  :status            => true,
  :project_classification => 1,
  :short_description =>'Mapping efforts to reduce poverty and suffering',
  :long_description  =>'On January 12th 2010, a catastrophic earthquake occured at Haiti, leaving more than 250.000 deaths and more than 1.000.000 homeless people. It was one of the biggest disasters in the century. Since then and until now, a huge effort has been made by some of the interaction members',
  :theme             => Theme.find_by_name('Garnet'),
  # :aid_map_image     => File.open(File.join(Rails.root, '/public/images/sites/haiti_img_example.jpg')),
  :navigate_by_level3 => true,
  :google_analytics_id => 'UA-20618946-2',
  :word_for_regions  => "Communes"
)

haiti_site_id = Site.find_by_name('Haiti Aid Map').id


##############################
# Generate pages
##############################

if (1==0)
  # ===> ABOUT PARENT PAGE
  haiti_about_page = Page.find_or_initialize_by_title_and_site_id('About', haiti_site_id)

  haiti_about_page.update_attributes(
    :title        => 'About',
    :body         => '',
    :site_id      => haiti_site_id,
    :permalink    => '',
    :published    => true,
    :parent_id    => nil,
    :order_index  => 0
  )

  haiti_about_page_id = haiti_about_page.id

  haiti_child_page = Page.find_or_initialize_by_title_and_site_id_and_parent_id('A-child-page', haiti_site_id, haiti_about_page_id)

  haiti_child_page.update_attributes(
    :title        => 'A-child-page',
    :body         => '',
    :site_id      => haiti_site_id,
    :permalink    => '',
    :published    => true,
    :parent_id    => nil,
    :order_index  => 0
  )

  # ===> DATA PARENT PAGE
  page = Page.find_or_initialize_by_title_and_site_id('Data', haiti_site_id)

  page.update_attributes(
    :title        => 'Data',
    :body         => '',
    :site_id      => haiti_site_id,
    :permalink    => '',
    :published    => true,
    :parent_id    => nil,
    :order_index  => 0
  )
  data_page_id = page.id
end


####################################################################
#
# FOOD AND SECURITY SITE
#
####################################################################

if (1==0)
  site = Site.find_or_initialize_by_name('Food Security')

  site.update_attributes(
    :name => 'Food Security',
    :url => "#{Rails.env.eql?('development') ? 'dev-' : ''}food.ngoaidmap.org",
    :status => true,
    :project_classification => 1,
    :short_description => 'Food security refers to the availability of food and one’s access to it',
    :long_description => 'The Special Programme for Food Security (SPFS) helps governments replicate successful food security practices on a national scale. The SPFS also encourages investment in rural infrastructure, off-farm income generation, urban agriculture and safety nets',
    :theme => Theme.find_by_name('Garnet'),
    # :aid_map_image => File.open(File.join(Rails.root, '/public/images/sites/food_img_example.jpg')),
    :navigate_by_country => true,
    :navigate_by_level1 => true,
    :word_for_regions => "Country"
  )
end

####################################################################
#
# GLOBAL SITE
#
####################################################################

global_site = Site.find_or_initialize_by_name('global')
global_id = global_site.id

global_site.update_attributes(
  :name => 'global',
  :url => "global.ngoaidmap.org",
  :status => true,
  :project_classification => 1,
  :short_description => 'Global site to unify all projects',
  :long_description => 'Global site to unify all projects',
  :theme => Theme.find_by_name('Garnet'),
  # :aid_map_image => File.open(File.join(Rails.root, '/public/images/sites/food_img_example.jpg')),
  :navigate_by_country => true,
  :navigate_by_level1 => true,
  :word_for_regions => "Country"
)


####################################################################
#
# GLOBAL PAGES
#
####################################################################


  # ===> DATA PARENT PAGE
  data_page = Page.find_or_create_by_title_and_site_id('Data', global_site.id)

  data_page.update_attributes(
    :title        => 'Data',
    :body         => '<h3>Top ten things you should know about the data.</h3>

                      <p>To try to ensure that visitors to our site understand the data and are interpreting it correctly, we’ve put together this list of things you should know about the information on this site. If there is something else that needs clarification, drop us a line at mappinginfo@interaction.org.</p>

                      <h3>Participation is limited to InterAction members.</h3>
                      <p>This site only features information on the work of InterAction members. While we recognize that this is only a partial picture of the work being done to reduce poverty and respond to crises or disasters, much of this information would not be available otherwise. By focusing on our members, which manage billions of dollars in public and private funding every year, our goal is to add to the information currently available about aid activities around the world.</p>

                      <h3>The site only contains information we receive directly from organizations.</h3>
                      <p>All data is provided to InterAction on a voluntary basis by member organizations, which are set up with an NGO Aid Map Member Workspace account where they can add or update data directly. InterAction does not gather information independently. Organizations may choose to report on all of their projects, or only a portion. To help visitors understand what portion of its work an organization has provided information on, organizations can provide additional information through an “organization form” which is listed as a resource on the site’s organization pages. This form provides information on how many active projects an organization has at any given time, how frequently an organization will update its data, etc.</p>

                      <h3>Data is updated at least three times a year.</h3>
                      <p>Members can update their data at any time, but InterAction sends out official "data calls" three times a year. </p>

                      <h3>Data is reviewed, but not vetted.</h3> 
                      <p>InterAction relies on its members to provide accurate and complete information on their activities. Members of InterAction must abide by a set of comprehensive Private Voluntary Organization (PVO) standards governing financial management, fundraising, governance and program performance in order to remain part of InterAction. While we cannot independently verify the information submitted, InterAction does review the data to check for inconsistencies and follows up with organizations, as needed.</p> 

                      <h3>Only active projects are displayed on the map.</h3>
                      <p>As projects end, they are automatically removed from the site. If you would like information on past projects, please contact us.</p>

                      <h3>Only seven fields are required.</h3>
                      <p>For a project to appear on NGO Aid Map, organizations must provide information on the following seven fields:</p>
                      <ul>
                        <li>Organization</li>
                        <li>Project Title</li>
                        <li>Project Description</li>
                        <li>Start Date</li>
                        <li>End Date</li>
                        <li>Sector</li>
                        <li>Country</li>
                      </ul>

                      <p>For more details about all the data fields, please see this short guidance document on providing project information and this guidance document on submitting information on in-kind donations.</p>

                      <h3>The bubbles on the map do not represent exact project locations.</h3>
                      <p>We encourage organizations to provide geographic information on their projects down to the state or province level (ADM1) whenever possible. When this information is provided, the bubble on the map corresponds to the center point of the state(s) in which that project takes place. If no sub-national geographic information is provided, the bubble corresponds to the center point of the country or countries in which that project takes place.</p>

                      <h3>One project can take place in multiple locations and be categorized under more than one sector.</h3>
                      <p>This means that you should not add up the number of projects across locations, or across sectors. For example, a project aimed at reducing chronic under-nutrition in children under five may involve working with health clinics to identify and treat malnourished children, as well as to improve access to clean water and sanitation in a community. This project would be coded under “health” as well as “water, sanitation and hygiene” and therefore would be included in the count for both sectors. If you added the number of projects by sector, you’d be counting this project twice: once under “health” and once under “water, sanitation and hygiene”.</p>

                      <h3>Different projects may target the same population.</h3>
                      <p>A given population may be the target of different projects by one or more organizations. For example, one organization may be working with a community to encourage clean hygiene, while another organization may be promoting the participation of women in that same community in public health activities. While some people in the community may only be involved in one project, some may be involved in both. Adding up the number of people reached for both projects would cause you to count some people twice. You should also keep in mind that organizations calculate the “number of people reached” differently.</p>

                      <h3>Both “prime” and sub-awardees may report on a project.</h3>
                      <p>Because we encourage all of our members to submit data to the site, this means that sometimes two or more organizations end up reporting on the same project: the prime awardee, which received funding directly from a donor, and one or more sub-awardees, who receive funding from the prime awardee to implement the project. These duplicates account for a small portion of the projects on the site, but to minimize overlaps we ask organizations to only report on the portion of the project they are responsible for implementing. We also ask organizations to identify the prime awardee of a project, so that it is possible to trace the flow of funding. For this reason, you should take care when adding up project budgets across organizations.</p>
                      ',
    :site_id      => global_id,
    :permalink    => 'data',
    :published    => true,
    :parent_id    => nil,
    :order_index  => 0
  )
  data_page_id = data_page.id



  # ===> DATA CHILD PAGE
  data_guidance_page = Page.find_or_create_by_title_and_site_id('Data guidance', global_site.id)

  data_guidance_page.update_attributes(
    :title        => 'Data guidance',
    :body         => '',
    :site_id      => global_id,
    :permalink    => 'data-guidance',
    :published    => true,
    :parent_id    => data_page_id,
    :order_index  => 0
  )


  # ===> ABOUT PARENT PAGE
  about_page = Page.find_or_create_by_title_and_site_id('About', global_site.id)

  about_page.update_attributes(
    :title        => 'About',
    :body         => '<p>InterAction’s NGO Aid Map aims to increase the amount of publicly available data on international development and humanitarian response by providing detailed project information through interactive maps and data visualizations.</p>
                      <p>See more.</p>
                      <ul>
                        <li><p>Learn more about NGO projects around the world.</p></li>
                        <li><p>Explore the site by country, sector, organization, or donor.</p></li>
                        <li><p>Gain a better a perspective on country contexts through map layers of relevant data, such as poverty levels or malnutrition rates.</p></li>
                      </ul>
                      <p>Do better.</p>
                      <ul>
                        <li><p>Locate potential partners and donors.</p></li>
                        <li><p>Identify gaps and avoid duplication.</p></li>
                        <li><p>Improve coordination.</p></li>
                        <li><p>Make smarter decisions through data analysis.</p></li>
                      </ul>
                      <p>Five principles underpin everything we do.</p>
                      <ul>
                        <li><p>Make it as easy as possible to share data. If it’s not easy, organizations won’t keep providing information, and there’s little value to a map that never gets updated.</p></li>
                        <li><p>Present the data in a way that makes it simple to understand and use. Our site is designed to make it easy to find the information people are looking for, to help them make the decisions they need to make.</p></li>
                        <li><p>Make the data open and accessible. We know there are many ways to slice and dice data. That’s why we’ve made it possible to download the data on every page of the site.</p></li>
                        <li><p>Do no harm. While we are strong advocates of openness, we realize there can be negative consequences to sharing data. We let organizations know that they should only share information if it is safe to do so, and review data that has been submitted to make sure that there isn’t anything that could put someone in harm’s way.</p></li>
                        <li><p>Collaborate with like-minded organizations also working to make more information available. NGO Aid Map is just one piece of the puzzle. By working with organizations who also see the value in open data, we hope to create a more complete picture of what is happening with international aid.</p></li>
                      </ul>
                      <p>Data is provided by our members on a voluntary basis, so the map is a partial picture of what our community does. Projects are continuously being added, so we encourage you to visit often to learn more about the work of InterAction members.</p>',
    :site_id      => global_id,
    :permalink    => 'about',
    :published    => true,
    :parent_id    => nil,
    :order_index  => 0
  )
  about_page_id = about_page.id



  # ===> ABOUT CHILD PAGE
  history_page = Page.find_or_create_by_title_and_site_id('History', global_site.id)

  history_page.update_attributes(
    :title        => 'History',
    :body         => '',
    :site_id      => global_id,
    :permalink    => 'history',
    :published    => true,
    :parent_id    => about_page_id,
    :order_index  => 1
  )

  about_interaction_page = Page.find_or_create_by_title_and_site_id('About InterAction', global_site.id)

  about_interaction_page.update_attributes(
    :title        => 'About InterAction',
    :body         => "<p>InterAction is an alliance organization in Washington, D.C. of nongovernmental organizations (NGOs). Our 180-plus members work around the world. What unites us is a commitment to working with the world's poor and vulnerable, and a belief that we can make the world a more peaceful, just and prosperous place – together.</p>
                      <p>InterAction serves as a convener, thought leader and voice of our community. Because we want real, long-term change, we work smarter: We mobilize our members to think and act collectively, because we know more is possible that way. We also know that how we get there matters. So we set high standards. We insist on respecting human dignity. We work in partnerships.</p>

                      <h3>Additional Information</h3>
                      <p>To learn more about InterAction and its work, visit <a href='http://www.interaction.org/'>InterAction’s website.</a></p>
                      <p>For a complete list of InterAction members, see <a href='http://www.interaction.org/members/about-members'>InterAction’s Member Directory.</a></p>",
    :site_id      => global_id,
    :permalink    => 'about-interAction',
    :published    => true,
    :parent_id    => about_page_id,
    :order_index  => 2
  )

  faq_page = Page.find_or_create_by_title_and_site_id('FAQ´s', global_site.id)

  faq_page.update_attributes(
    :title        => 'FAQ´s',
    :body         => '<div id="faqAccordion">
                      <h3>What is NGO Aid Map?</h3>
                      <div>
                        <p>NGO Aid Map is an InterAction initiative that provides detailed information on our members’ work around the world through a web-based mapping platform. Read more here. </p>
                      </div>

                      <h3>Who funds this initiative?</h3>
                      <div>
                        <p>NGO Aid Map is supported by FedEx and the International Fund for Agricultural Development (IFAD).</p>
                      </div>

                      <h3>Why is mapping NGO data important?</h3>
                      <div>
                        <p>By making information on NGO activities easily accessible, NGO Aid Map strives to:</p>
                        <ul>
                          <li>Promote transparency.</li>
                          <li>Facilitate partnerships and improve coordination.</li>
                          <li>Publicize the work of NGOs.</li>
                          <li>Help guide decisions about where to direct aid resources.</li>
                          <li>Inform advocacy and influence policy.</li>
                        </ul>
                      </div>

                      <h3>Who can participate? Which organizations are represented on this site?</h3>
                      <div>
                        <p>Only InterAction member organizations can participate and contribute data to NGO Aid Map at this time, and their participation is completely voluntary. NGO Aid Map features information on InterAction members working either directly on the ground, or indirectly through local or international partners.</p>
                      </div>

                      <h3>What data is available?</h3>
                      <div>
                        <p>On the home page, you will find a world map with all active projects that have been added by InterAction members. You can filter this information by donor, location, sector, or implementing organization. Additionally, you view the map with additional layers of additional data sets, such as poverty rates, to help provide further context. Read more about the data here.</p>
                      </div>

                      <h3>Why do some countries have very few projects?</h3>
                      <div>
                        <p>Data is provided by our members on a voluntary basis, so the map is a partial picture of what our community does. Projects are continuously being added, so we encourage you to visit often to learn more about the work of InterAction members.</p>
                      </div>

                      <h3>How often is the information updated?</h3>
                      <div>
                        <p>InterAction members can log in to NGO Aid Map at any time to add or update data. Our team facilitates three data calls a year to help ensure organizations keep their data up to date.</p>
                      </div>

                      <h3>Is the data on the site vetted?</h3>
                      <div>
                        <p>No. InterAction relies on its members and other participating organizations to provide accurate and complete information on their work. We review the data to check for inconsistencies, code the data by sector, and follow up with organizations as needed to ensure that their information is as complete as possible. However, InterAction cannot independently verify the accuracy of the information submitted.</p>
                      </div>

                      <h3>How can organizations participate in the NGO Aid Map?</h3>
                      <div>
                        <p>Only InterAction members can participate in NGO Aid Map at this time (find out how to apply to become an InterAction member). If you are an InterAction member, please contact us at MappingInfo@InterAction.org for more information on how to start adding your data to the map.</p>
                      </div>

                      <h3>What data do InterAction members have to share to submit a project to NGO Aid Map?</h3>
                      <div>
                        <p>We encourage members to add as much project data as possible, including budget, pictures and videos, and contact information. For a project to become active on NGO Aid Map, the InterAction member organization must share the following minimum amount of information:</p>
                        <ul>
                          <li>Organization name.</li>
                          <li>Project description.</li>
                          <li>Start date.</li>
                          <li>End date.</li>
                          <li>Sector(s).</li>
                          <li>Country.</li>
                        </ul>
                      </div>

                      <h3>Where does InterAction promote NGO Aid Map?</h3>
                      <div>
                        <p>InterAction promotes NGO Aid Map in many places. We present NGO Aid Map at international expos, forums, and meetings all over the world. NGO Aid Map is highlighted in communications with our members, who are encouraged to feature their projects on the map in their own outreach.</p>
                        <p>The Mapping Team at InterAction works across the international aid, data, transparency, and technology sectors, and we promote our initiative in all these spheres. Online, they are featured on the InterAction website and NGO Aid Maps’ social media accounts.</p>
                      </div>

                      <h3>Is NGO Aid Map open source?</h3>
                      <div>
                        <p>Yes, the project is released on Open Source. You can find the source at Github. The project also makes extensive use of other Open Source projects like PostgreSQL, PostGIS, Ruby on Rails and many other projects. If you would like to contribute to the project or you are interested in contacting the development team, send an email to <a href="mailto:contact@vizzuality.com">contact@vizzuality.com</a></p>
                      </div>

                      <h3>Can I use the data from NGO Aid Map?</h3>
                      <div>
                        <p>Yes, the data on NGO Aid Map is made available under the Open Data Commons Attribution (ODC-BY 1.0) License. This states that you can use the use the data as long as you cite NGO Aid Map as the source.</p>
                      </div>
                    </div>',
    :site_id      => global_id,
    :permalink    => 'faq',
    :published    => true,
    :parent_id    => about_page_id,
    :order_index  => 3
  )

  news_and_updates_page = Page.find_or_create_by_title_and_site_id('News and updates', global_site.id)

  news_and_updates_page.update_attributes(
    :title        => 'News and updates',
    :body         => '<h3>Blogs</h3>
                      <p>In 2013, NGO Aid Map produced a blog series looking at the lessons learned and challenges encountered over the two years since our initiative launched. This series was written by Laia Grino, Manager of Transparency, Accountability and Results at InterAction.</p>
                      <ul>
                        <li><a href="#">Two Years Older and Wiser</a></li>
                        <li><a href="#">We Built It. Have They Come? (Part 1: Incentives)</a></li>
                        <li><a href="#">We Built It. Have They Come? (Part 2: Making it Easy to Participate)</a></li>
                        <li><a href="#">The Tricky Question of Use</a></li>
                        <li><a href="#">Go Wide or Go Deep?</a></li>
                      </ul>

                      <h3>Newsletter Archive</h3>
                      <ul>
                        <li><a href="#">2014</a></li>
                        <li><a href="#">2013</a></li>
                        <li><a href="#">2012</a></li>
                        <li><a href="#">2011</a></li>
                      </ul>',
    :site_id      => global_id,
    :permalink    => 'news-and-updates',
    :published    => true,
    :parent_id    => about_page_id,
    :order_index  => 4
  )

  mapping_team_page = Page.find_or_create_by_title_and_site_id('Mapping team', global_site.id)

  mapping_team_page.update_attributes(
    :title        => 'Mapping team',
    :body         => '<p>Julie Montgomery is the Director of NGO Aid Map and has been leading the initiative since its inception. Read <a href="http://www.interaction.org/users/julie-montgomery" target="_blank">Julie’s full bio on InterAction’s website.</a></p>

                      <p>Laia Grino manages the data and outreach for NGO Aid Map. Laia is responsible for the data quality and standards for the map. Read <a href="http://www.interaction.org/users/laia-grino" target="_blank">Laia’s full bio on InterAction’s website.</a></p>

                      <p>Kellie Peake helps lead marketing, communications and social media for NGO Aid Map. Read <a href="http://www.interaction.org/users/kellie-peake" target="_blank">Kellie’s full bio on InterAction’s website.</a></p>

                      <p>Joe McGrann handles all member outreach for NGO Aid Map. Read <a href="http://www.interaction.org/users/joseph-mcgrann" target="_blank">Joe’s full bio on InterAction’s website.</a></p>

                      <p>Robert Burnett is NGO Aid Map’s Data Fellow and is responsible for developing data analysis and visualizations. Read <a href="" target="_blank">Robert’s full bio on InterAction’s website</a></p>

                      <h3>Contact Us</h3>
                      <p>If you have any questions or would like to learn more about NGO Aid Map, please contact us and a member of InterAction’s mapping team will contact you promptly.</p>
                      <a href="mailto:mappingInfo@InterAction.org">MappingInfo@InterAction.org</a>',
    :site_id      => global_id,
    :permalink    => 'mapping-team',
    :published    => true,
    :parent_id    => about_page_id,
    :order_index  => 5
  )

  contact_page = Page.find_or_create_by_title_and_site_id('Contact', global_site.id)

  contact_page.update_attributes(
    :title        => 'Contact',
    :body         => '<p>Julie Montgomery is the Director of NGO Aid Map and has been leading the initiative since its inception. Read <a href="http://www.interaction.org/users/julie-montgomery" target="_blank">Julie’s full bio on InterAction’s website.</a></p>

                      <p>Laia Grino manages the data and outreach for NGO Aid Map. Laia is responsible for the data quality and standards for the map. Read <a href="http://www.interaction.org/users/laia-grino" target="_blank">Laia’s full bio on InterAction’s website.</a></p>

                      <p>Kellie Peake helps lead marketing, communications and social media for NGO Aid Map. Read <a href="http://www.interaction.org/users/kellie-peake" target="_blank">Kellie’s full bio on InterAction’s website.</a></p>

                      <p>Joe McGrann handles all member outreach for NGO Aid Map. Read <a href="http://www.interaction.org/users/joseph-mcgrann" target="_blank">Joe’s full bio on InterAction’s website.</a></p>

                      <p>Robert Burnett is NGO Aid Map’s Data Fellow and is responsible for developing data analysis and visualizations. Read <a href="" target="_blank">Robert’s full bio on InterAction’s website</a></p>

                      <h3>Contact Us</h3>
                      <p>If you have any questions or would like to learn more about NGO Aid Map, please contact us and a member of InterAction’s mapping team will contact you promptly.</p>
                      <a href="mailto:mappingInfo@InterAction.org">MappingInfo@InterAction.org</a>',
    :site_id      => global_id,
    :permalink    => 'contact',
    :published    => true,
    :parent_id    => about_page_id,
    :order_index  => 6
  )






####################################################################
#
# SECTORS
#
####################################################################

Sector.find_or_create_by_name :name => 'Neglected Tropical Diseases (NTDs)'
Sector.find_or_create_by_name :name => 'Water, Sanitation, Hygiene (WASH)'
Sector.find_or_create_by_name :name => 'Education'
Sector.find_or_create_by_name :name => 'Nutrition'
Sector.find_or_create_by_name :name => 'Agriculture'
Sector.find_or_create_by_name :name => 'Immunization'


####################################################################
#
# Medicines
#
####################################################################

Medicine.find_or_create_by_name :name => 'Albendazole'
Medicine.find_or_create_by_name :name => 'Mebendazole'
Medicine.find_or_create_by_name :name => 'Ivermectin (Mectizan)'
Medicine.find_or_create_by_name :name => 'Diethylcarbamazine citrate (DEC)'
Medicine.find_or_create_by_name :name => 'Azithromycin'
Medicine.find_or_create_by_name :name => 'Praziquantel'

####################################################################
#
# Diseases
#
####################################################################

Disease.find_or_create_by_name :name => 'Soil-transmitted Helminthiasis'
Disease.find_or_create_by_name :name => 'Lymphatic Filariasis'
Disease.find_or_create_by_name :name => 'Trachoma'
Disease.find_or_create_by_name :name => 'Schistosomiasis'
Disease.find_or_create_by_name :name => 'Onchocerciasis'
Disease.find_or_create_by_name :name => 'Dengue'
Disease.find_or_create_by_name :name => 'Rabies'
Disease.find_or_create_by_name :name => 'Chagas'
Disease.find_or_create_by_name :name => 'Leishmaniasis'
Disease.find_or_create_by_name :name => 'Buruli ulcer'
Disease.find_or_create_by_name :name => 'Leprosy'
Disease.find_or_create_by_name :name => 'Yaws'
Disease.find_or_create_by_name :name => 'Echinococcosis'
Disease.find_or_create_by_name :name => 'African Trypanosomiasis'
Disease.find_or_create_by_name :name => 'Cysticercosis / Taeniasis'
Disease.find_or_create_by_name :name => 'Guinea Worm Disease'
Disease.find_or_create_by_name :name => 'Foodborne Trematodiasis'
Disease.find_or_create_by_name :name => 'HIV / AIDS'
Disease.find_or_create_by_name :name => 'Tuberculosis'
Disease.find_or_create_by_name :name => 'Malaria'
Disease.find_or_create_by_name :name => 'Anemia'
Disease.find_or_create_by_name :name => 'Vitamin A Deficiency'
Disease.find_or_create_by_name :name => 'Malnutrition'

####################################################################
#
# Activities
#
####################################################################

Activity.find_or_create_by_name :name => 'Drug Treatment (including preventive chemotherapy)'
Activity.find_or_create_by_name :name => 'Water Intervention'
Activity.find_or_create_by_name :name => 'Sanitation Intervention'
Activity.find_or_create_by_name :name => 'Hygiene Education'
Activity.find_or_create_by_name :name => 'Vitamin A Distribution'
Activity.find_or_create_by_name :name => 'Iron / Folic Acid Distribution'
Activity.find_or_create_by_name :name => 'Other Micronutrient Supplementation'
Activity.find_or_create_by_name :name => 'Surgery'
Activity.find_or_create_by_name :name => 'Immunization'
Activity.find_or_create_by_name :name => 'Logistics / Supply Chain'
Activity.find_or_create_by_name :name => 'Research'
Activity.find_or_create_by_name :name => 'Advocacy'
Activity.find_or_create_by_name :name => 'Monitoring / Evaluation'
Activity.find_or_create_by_name :name => 'Technical Support'
Activity.find_or_create_by_name :name => 'Capacity Building / Training'
Activity.find_or_create_by_name :name => 'Other'


####################################################################
#
# Audience
#
####################################################################

Audience.find_or_create_by_name :name => 'Infants'
Audience.find_or_create_by_name :name => 'Pre-school Children'
Audience.find_or_create_by_name :name => 'School-age Children'
Audience.find_or_create_by_name :name => 'Women of Reproductive Age'
Audience.find_or_create_by_name :name => 'Pregnant Women'
Audience.find_or_create_by_name :name => 'Adult Men'
Audience.find_or_create_by_name :name => 'Health Workers'
Audience.find_or_create_by_name :name => 'Academia'
Audience.find_or_create_by_name :name => 'Policymakers'
Audience.find_or_create_by_name :name => 'Donors'

