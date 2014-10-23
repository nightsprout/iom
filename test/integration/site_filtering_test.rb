require File.expand_path('../../test_helper', __FILE__)

class SiteFilteringTest < ActionController::IntegrationTest

  test "Given a main domain and two sites in two subdomains, the application should route the request to the appropiate site" do
    host = 'example.com'
    global_site = create_site :global
    site1 = create_site :url => "site1.#{host}", :status => true
    site2 = create_site :url => "site2.#{host}", :status => true
    donor = create_donor

    host!(host)
    get "/"
    assert_response :success
    assert_equal global_site, assigns(:site)

    host!(site1.url)
    get "/", force_site_id: site1.id
    assert_response :success
    assert_equal site1, assigns(:site)

    host!(site2.url)
    get "/", force_site_id: site2.id
    assert_response :success
    assert_equal site2, assigns(:site)

  end
  
end
