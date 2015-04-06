<#ftl encoding="utf-8" />
<#import "/web/templates/modernui/funnelback_classic.ftl" as s/>
<#import "/web/templates/modernui/funnelback.ftl" as fb/>
<#escape x as x?html>
<#-- 
  Sets HTML encoding as the default for this file only - use <#noescape>...</#noescape> around anything which should not be escaped.
  Note that if you include macros from another file, they are not affected by this and must hand escaping themselves
  Either by using a similar escape block, or ?html escapes inline.
-->
<div class="fb-container">

  <@s.InitialFormOnly><#-- Content to be displayed when there is no query parameter --></@s.InitialFormOnly>

  <@s.AfterSearchOnly>

  <div class="fb-search-form collapse navbar-collapse">
    <form class="navbar-form navbar-left form-inline" action="${question.collection.configuration.value("ui.modern.search_link")}" method="GET" role="search">
      <input type="hidden" name="collection" value="${question.inputParameterMap["collection"]!}">
      <@s.IfDefCGI name="enc"><input type="hidden" name="enc" value="${question.inputParameterMap["enc"]!}"></@s.IfDefCGI>
      <@s.IfDefCGI name="form"><input type="hidden" name="form" value="${question.inputParameterMap["form"]!}"></@s.IfDefCGI>
      <@s.IfDefCGI name="scope"><input type="hidden" name="scope" value="${question.inputParameterMap["scope"]!}"></@s.IfDefCGI>
      <@s.IfDefCGI name="lang"><input type="hidden" name="lang" value="${question.inputParameterMap["lang"]!}"></@s.IfDefCGI>
      <@s.IfDefCGI name="profile"><input type="hidden" name="profile" value="${question.inputParameterMap["profile"]!}"></@s.IfDefCGI>
      <div class="form-group">
        <input required name="query" id="query" title="Search query" type="text" value="${question.inputParameterMap["query"]!}" accesskey="q" placeholder="Search <@s.cfg>service_name</@s.cfg>&hellip;" class="form-control query">
      </div>
      <input type="submit" class="btn btn-primary" value="Search"/>
      <div class="checkbox-inline">
        <@s.FacetScope> Within selected categories only</@s.FacetScope>
      </div>
    </form>
  </div>

    <div class="row">

      <div class="col-md-<@s.FacetedSearch>9 col-md-push-3</@s.FacetedSearch><@s.FacetedSearch negate=true>12</@s.FacetedSearch>">

        <#if question.collection.configuration.valueAsBoolean("ui.modern.session") && session.searchHistory?? && session.searchHistory?size &gt; 0>
          <#-- Build list of previous queries -->

          <#assign qsSignature = computeQueryStringSignature(QueryString) />
          <#if session.searchHistory?? &&
            (session.searchHistory?size &gt; 1 || session.searchHistory[0].searchParamsSignature != qsSignature)>
            <div class="breadcrumb" data-ng-controller="SearchHistoryCtrl" data-ng-show="!searchHistoryEmpty">
                <button class="btn btn-link pull-right" data-ng-click="toggleHistory()"><small class="text-muted"><span class="glyphicon glyphicon-plus"></span> More&hellip;</small></button>
                <ol class="list-inline" >
                  <li class="text-muted">Recent:</li>

                  <#list session.searchHistory as h>
                    <#if h.searchParamsSignature != qsSignature>
                      <#assign facetDescription><#compress>
                      <#list h.searchParams?matches("f\\.([^=]+)=([^&]+)") as f>
                          ${urlDecode(f?groups[1])?split("|")[0]} = ${urlDecode(f?groups[2])}<#if f_has_next><br></#if>
                      </#list>
                      </#compress></#assign>
                      <li>
                        <a <#if facetDescription != ""> data-toggle="tooltip" data-placement="bottom" title="${facetDescription}"</#if> title="${prettyTime(h.searchDate)}" href="${question.collection.configuration.value("ui.modern.search_link")}?${h.searchParams}">${h.originalQuery} <small>(${h.totalMatching})</small></a>
                        <#if facetDescription != ""><i class="glyphicon glyphicon-filter"></i></a></#if>
                      </li>
                    </#if>
                  </#list>
                </ol>
            </div>
          </#if>
        </#if>

        <#if question.inputParameterMap["scope"]!?length != 0>
          <div class="breadcrumb">
            <span class="text-muted"><span class="glyphicon glyphicon-resize-small"></span> Scope:</span> <@s.Truncate length=80>${question.inputParameterMap["scope"]!}</@s.Truncate>
            <a class="button btn-xs" title="Remove scope: ${question.inputParameterMap["scope"]!}" href="?collection=${question.inputParameterMap["collection"]!}<#if question.inputParameterMap["form"]??>&amp;form=${question.inputParameterMap["form"]!}</#if>&amp;query=<@s.URLEncode><@s.QueryClean /></@s.URLEncode>"><span class="glyphicon glyphicon-remove text-muted"></span></a>
          </div>
        </#if>

        <div id="search-result-count" class="text-muted">
          <#if response.resultPacket.resultsSummary.totalMatching == 0>
            <span id="search-total-matching">0</span> search results for <strong><@s.QueryClean /></strong>
          </#if>
          <#if response.resultPacket.resultsSummary.totalMatching != 0>
            <span id="search-page-start">${response.resultPacket.resultsSummary.currStart}</span> -
            <span id="search-page-end">${response.resultPacket.resultsSummary.currEnd}</span> of
            <span id="search-total-matching">${response.resultPacket.resultsSummary.totalMatching?string.number}</span>
            <#if question.inputParameterMap["s"]?? && question.inputParameterMap["s"]?contains("?:")><em>collapsed</em> </#if>search results for <strong><@s.QueryClean></@s.QueryClean></strong>
          </#if>

          <#if (response.resultPacket.resultsSummary.partiallyMatching!0) != 0>
              where <span id="search-fully-matching">${response.resultPacket.resultsSummary.fullyMatching?string.number}</span>
              match all words and <span id="search-partially-matching">${response.resultPacket.resultsSummary.partiallyMatching?string.number}</span>
              match some words.
          </#if>
          <#if (response.resultPacket.resultsSummary.collapsed!0) != 0>
                <span id="search-collapsed">${response.resultPacket.resultsSummary.collapsed}</span>
                very similar results included.
          </#if>
        </div>

        <#if (response.resultPacket.QSups)!?size &gt; 0>
          <div class="alert alert-info">
            <@fb.CheckBlending linkText="Search for <em>"+question.originalQuery+"</em> instead." tag="strong" />
          </div>
        </#if>

        <#if (response.curator.exhibits)!?size &gt; 0>
          <#list response.curator.exhibits as exhibit>
            <#if exhibit.messageHtml??>
              <blockquote class="search-curator-message">
                <#noescape>${exhibit.messageHtml}</#noescape>
              </blockquote>
            </#if>
          </#list>
        </#if>

        <@s.CheckSpelling prefix="<h3 id=\"search-spelling\"><span class=\"glyphicon glyphicon-question-sign text-muted\"></span> Did you mean <em>" suffix="</em>?</h3>" />

        <h2 class="visible-print">Results</h2>

        <#if response.resultPacket.resultsSummary.totalMatching == 0>
            <h3><span class="glyphicon glyphicon-warning-sign"></span> No results</h3>
            <p>Your search for <strong>${question.originalQuery!}</strong> did not return any results. Please ensure that you:</p>
            <ul>
              <li>are not using any advanced search operators like + - | " etc.</li> 
              <li>expect this document to exist within the <em><@s.cfg>service_name</@s.cfg></em> collection <@s.IfDefCGI name="scope"> and within <em><@s.Truncate length=80>${question.inputParameterMap["scope"]!}</@s.Truncate></em></@s.IfDefCGI></li>
              <li>have permission to see any documents that may match your query</li>
            </ul>
        </#if>


        <#if (response.resultPacket.bestBets)!?size &gt; 0>
          <ol id="search-best-bets" class="list-unstyled">
          <@s.BestBets>
            <li class="alert alert-warning">
              <#if s.bb.title??><h4><a href="${s.bb.clickTrackingUrl}"><@s.boldicize>${s.bb.title}</@s.boldicize></a></h4></#if>
              <#if s.bb.title??><cite class="text-success">${s.bb.link}</cite></#if>
              <#if s.bb.description??><p><@s.boldicize><#noescape>${s.bb.description}</#noescape></@s.boldicize></p></#if>
              <#if ! s.bb.title??><p><strong>${s.bb.trigger}:</strong> <a href="${s.bb.link}">${s.bb.link}</a></#if>
            </li>
          </@s.BestBets>
          </ol>
        </#if>

        <ol id="search-results" class="list-unstyled" start="${response.resultPacket.resultsSummary.currStart}">
          <@s.Results>
            <#if s.result.class.simpleName == "TierBar">
              <#-- A tier bar -->
              <#if s.result.matched != s.result.outOf>
                <li class="search-tier"><h3 class="text-muted">Results that match ${s.result.matched} of ${s.result.outOf} words</h3></li>
              <#else>
                <li class="search-tier"><h3 class="hidden">Fully-matching results</h3></li>
              </#if>
              <#-- Print event tier bars if they exist -->
              <#if s.result.eventDate??>
                <h2 class="fb-title">Events on ${s.result.eventDate?date}</h2>
              </#if>
            <#else>
              <li data-fb-result=${s.result.indexUrl}>

                <h4>
                  <#if question.collection.configuration.valueAsBoolean("ui.modern.session")><a href="#" data-ng-click="toggle()" data-cart-link data-css="pushpin|remove" title="{{label}}"><small class="glyphicon glyphicon-{{css}}"></small></a></#if>

                  <a href="${s.result.clickTrackingUrl}" title="${s.result.liveUrl}">
                    <@s.boldicize><@s.Truncate length=70>${s.result.title}</@s.Truncate></@s.boldicize>
                  </a>
                  <#if s.result.fileType!?matches("(doc|docx|ppt|pptx|rtf|xls|xlsx|xlsm|pdf)", "r")>
                    <small class="text-muted">${s.result.fileType?upper_case} (${filesize(s.result.fileSize!0)})</small>
                  </#if>
                  <#if question.collection.configuration.valueAsBoolean("ui.modern.session") && session?? && session.getClickHistory(s.result.indexUrl)??><small class="text-warning"><span class="glyphicon glyphicon-time"></span> <a title="Click history" href="#" class="text-warning" data-ng-click="toggleHistory()">Last visited ${prettyTime(session.getClickHistory(s.result.indexUrl).clickDate)}</a></small></#if>
                </h4>

                <cite data-url="${s.result.displayUrl}" class="text-success"><@s.cut cut="http://"><@s.boldicize>${s.result.displayUrl}</@s.boldicize></@s.cut></cite>
                <div class="btn-group">
                  <a href="#" class="dropdown-toggle" data-toggle="dropdown" title="More actions&hellip;"><small class="glyphicon glyphicon-chevron-down text-success"></small></a>
                  <ul class="dropdown-menu">
                    <li><#if s.result.cacheUrl??><a href="${s.result.cacheUrl}&amp;hl=${response.resultPacket.queryHighlightRegex!?url}" title="Cached version of ${s.result.title} (${s.result.rank})">Cached</a></#if></li>
                    <li><@s.Explore /></li>
                    <@fb.AdminUIOnly><li><@fb.Optimise /></li></@fb.AdminUIOnly>
                  </ul>
                </div>

                <@s.Quicklinks>
                  <ul class="list-inline">
                      <@s.QuickRepeat><li><a href="${s.ql.url}" title="${s.ql.text}">${s.ql.text}</a></li></@s.QuickRepeat>
                  </ul>
                  <#if question.collection.quickLinksConfiguration["quicklinks.domain_searchbox"]?? && question.collection.quickLinksConfiguration["quicklinks.domain_searchbox"] == "true">
                    <#if s.result.quickLinks.domain?matches("^[^/]*/?[^/]*$", "r")>
                      <form action="${question.collection.configuration.value("ui.modern.search_link")}" method="GET" role="search">
                          <input type="hidden" name="collection" value="${question.inputParameterMap["collection"]!}">
                          <input type="hidden" name="meta_u_sand" value="${s.result.quickLinks.domain}">
                          <@s.IfDefCGI name="enc"><input type="hidden" name="enc" value="${question.inputParameterMap["enc"]!}"></@s.IfDefCGI>
                          <@s.IfDefCGI name="form"><input type="hidden" name="form" value="${question.inputParameterMap["form"]!}"></@s.IfDefCGI>
                          <@s.IfDefCGI name="scope"><input type="hidden" name="scope" value="${question.inputParameterMap["scope"]!}"></@s.IfDefCGI>
                          <@s.IfDefCGI name="profile"><input type="hidden" name="profile" value="${question.inputParameterMap["profile"]!}"></@s.IfDefCGI>
                          <div class="row">
                            <div class="col-md-4">
                            <div class="input-group input-sm">
                              <input required title="Search query" name="query" type="text" class="form-control" placeholder="Search ${s.result.quickLinks.domain}&hellip;">
                              <div class="input-group-btn">
                                <button type="submit" class="btn btn-info"><span class="glyphicon glyphicon-search"></span></button>
                              </div>
                            </div>
                          </div>
                        </div>
                      </form>
                    </#if>
                  </#if>
                </@s.Quicklinks>

                <#if s.result.summary??>
                  <p>
                    <#if s.result.date??><small class="text-muted">${s.result.date?date?string("d MMM yyyy")}:</small></#if>
                    <span class="search-summary"><@s.boldicize><#noescape>${s.result.summary}</#noescape></@s.boldicize></span>
                  </p>
                </#if>
                <#if s.result.metaData["c"]??><p><@s.boldicize>${s.result.metaData["c"]!}</@s.boldicize></p></#if>

                <#if s.result.collapsed??>
                  <div class="search-collapsed"><small><span class="glyphicon glyphicon-expand text-muted"></span>&nbsp; <@fb.Collapsed /></small></div>
                </#if>

                <#if s.result.metaData["a"]?? || s.result.metaData["s"]?? || s.result.metaData["p"]??>
                  <dl class="dl-horizontal text-muted">
                  <#if s.result.metaData["a"]??><dt>by</dt><dd>${s.result.metaData["a"]!?replace("|", ", ")}</dd></#if>
                  <#if s.result.metaData["s"]??><dt>Keywords:</dt><dd>${s.result.metaData["s"]!?replace("|", ", ")}</dd></#if>
                  <#if s.result.metaData["p"]??><dt>Publisher:</dt><dd>${s.result.metaData["p"]!?replace("|", ", ")}</dd></#if>
                  </dl>
                </#if>
              </li>
            </#if>
          </@s.Results>
        </ol>

        <@s.ContextualNavigation>
            <@s.ClusterNavLayout />
            <@s.NoClustersFound />
            <@s.ClusterLayout>
              <div class="well" id="search-contextual-navigation">
                <h3>Related searches for <strong><@s.QueryClean /></strong></h3>
                <div class="row">
                  <@s.Category name="type">
                    <div class="col-md-4 search-contextual-navigation-type">
                      <h4>Types of <strong>${s.contextualNavigation.searchTerm}</strong></h4>
                      <ul class="list-unstyled">
                        <@s.Clusters><li><a href="${s.cluster.href}"> <#noescape>${s.cluster.label?html?replace("...", " <strong>"+s.contextualNavigation.searchTerm?html+"</strong> ")}</#noescape></a></li></@s.Clusters>
                        <@s.ShowMoreClusters category="type"><li><a rel="more" href="${changeParam(s.category.moreLink, "type_max_clusters", "40")}" class="btn btn-link btn-sm"><small class="glyphicon glyphicon-plus"></small> More&hellip;</a></li></@s.ShowMoreClusters>
                        <@s.ShowFewerClusters category="type" />
                      </ul>
                    </div>
                  </@s.Category>

                  <@s.Category name="topic">
                      <div class="col-md-4 search-contextual-navigation-topic">
                        <h4>Topics on <strong>${s.contextualNavigation.searchTerm}</strong></h4>
                        <ul class="list-unstyled">
                          <@s.Clusters><li><a href="${s.cluster.href}"> <#noescape>${s.cluster.label?html?replace("...", " <strong>"+s.contextualNavigation.searchTerm?html+"</strong> ")}</#noescape></a></li></@s.Clusters>
                          <@s.ShowMoreClusters category="topic"><li><a rel="more" href="${changeParam(s.category.moreLink, "topic_max_clusters", "40")}" class="btn btn-link btn-sm"><small class="glyphicon glyphicon-plus"></small> More&hellip;</a></li></@s.ShowMoreClusters>
                          <@s.ShowFewerClusters category="topic" />
                        </ul>
                      </div>
                  </@s.Category>

                  <@s.Category name="site">
                      <div class="col-md-4 search-contextual-navigation-site">
                        <h4><strong>${s.contextualNavigation.searchTerm}</strong> by site</h4>
                        <ul class="list-unstyled">
                          <@s.Clusters><li><a href="${s.cluster.href}"> ${s.cluster.label}</a></li></@s.Clusters>
                          <@s.ShowMoreClusters category="site"><li><a rel="more" href="${changeParam(s.category.moreLink, "site_max_clusters", "40")}" class="btn btn-link btn-sm"><small class="glyphicon glyphicon-plus"></small> More&hellip;</a></li></@s.ShowMoreClusters>
                          <@s.ShowFewerClusters category="site" />
                        </ul>
                      </div>
                  </@s.Category>
                </div>
              </div>
            </@s.ClusterLayout>
        </@s.ContextualNavigation>

        <div class="text-center hidden-print">
          <h2 class="sr-only">Pagination</h2>
          <ul class="pagination pagination-lg">
            <@fb.Prev><li><a href="${fb.prevUrl}" rel="prev"><small><i class="glyphicon glyphicon-chevron-left"></i></small> Prev</a></li></@fb.Prev>
            <@fb.Page numPages=5><li <#if fb.pageCurrent> class="active"</#if>><a href="${fb.pageUrl}">${fb.pageNumber}</a></li></@fb.Page>
            <@fb.Next><li><a href="${fb.nextUrl}" rel="next">Next <small><i class="glyphicon glyphicon-chevron-right"></i></small></a></li></@fb.Next>
          </ul>
        </div>

      </div>

      <@s.FacetedSearch>
        <div class="col-md-3 col-md-pull-9 hidden-print" id="search-facets">
          <h2 class="sr-only">Refine</h2>
          <@s.Facet>
            <div class="panel panel-default">
              <div class="panel-heading"><@s.FacetLabel tag="h3"/></div>
              <div class="panel-body">
                <ul class="list-unstyled">
                  <@s.Category tag="li">
                    <@s.CategoryName class="" />&nbsp;<span class="badge pull-right"><@s.CategoryCount /></span>
                  </@s.Category>
                </ul>
                <button type="button" class="btn btn-link btn-sm search-toggle-more-categories" style="display: none;" data-more="More&hellip;" data-less="Less&hellip;" data-state="more" title="Show more categories from this facet"><small class="glyphicon glyphicon-plus"></small>&nbsp;<span>More&hellip;</span></button>
              </div>
            </div>
          </@s.Facet>
        </div>
      </@s.FacetedSearch>
    </div>

</@s.AfterSearchOnly>

</div>

<#-- JS required for query completion
<script src="${SearchPrefix}js/jquery/jquery-1.10.2.min.js"></script>
<script src="${SearchPrefix}js/jquery/jquery-ui-1.10.3.custom.min.js"></script>
<script src="${SearchPrefix}thirdparty/bootstrap-3.0.0/js/bootstrap.min.js"></script>
<script src="${SearchPrefix}js/jquery/jquery.tmpl.min.js"></script>
<script src="${SearchPrefix}js/jquery.funnelback-completion.js"></script>

<script>
  jQuery(document).ready( function() {

    // jQuery.widget.bridge('uitooltip', jQuery.ui.tooltip); 

    jQuery('[data-toggle=tooltip]').tooltip({'html': true});

    // Query completion setup.
    jQuery("input.query").fbcompletion({
      'enabled'    : '<@s.cfg>query_completion</@s.cfg>',
      'standardCompletionEnabled': <@s.cfg>query_completion.standard.enabled</@s.cfg>,
      'collection' : '<@s.cfg>collection</@s.cfg>',
      'program'    : '${SearchPrefix}<@s.cfg>query_completion.program</@s.cfg>',
      'format'     : '<@s.cfg>query_completion.format</@s.cfg>',
      'alpha'      : '<@s.cfg>query_completion.alpha</@s.cfg>',
      'show'       : '<@s.cfg>query_completion.show</@s.cfg>',
      'sort'       : '<@s.cfg>query_completion.sort</@s.cfg>',
      'length'     : '<@s.cfg>query_completion.length</@s.cfg>',
      'delay'      : '<@s.cfg>query_completion.delay</@s.cfg>',
      'profile'    : '${question.inputParameterMap["profile"]!}',
      'query'      : '${QueryString}',
      //Search based completion
      'searchBasedCompletionEnabled': <@s.cfg>query_completion.search.enabled</@s.cfg>,
      'searchBasedCompletionProgram': '${SearchPrefix}<@s.cfg>query_completion.search.program</@s.cfg>',
    });

    // Faceted Navigation more/less links
    var displayedCategories = 8;

    jQuery('div.facet ul').each( function() {
        jQuery(this).children('li:gt('+(displayedCategories-1)+')').hide();
    });

    jQuery('.search-toggle-more-categories').each( function() {
      var nbCategories = jQuery(this).parent().parent().find('li').size();
      if ( nbCategories <= displayedCategories ) {
        jQuery(this).hide();
      } else {
        jQuery(this).css('display', 'block');
        jQuery(this).click( function() {
          if (jQuery(this).attr('data-state') === 'less') {
            jQuery(this).attr('data-state', 'more');
            jQuery(this).parent().parent().find('li:gt('+(displayedCategories-1)+')').hide();
            jQuery(this).find('span').text(jQuery(this).attr('data-more'));
          } else {
            jQuery(this).attr('data-state', 'less');
            jQuery(this).parent().parent().find('li').css('display', 'block');
            jQuery(this).find('span').text(jQuery(this).attr('data-less'));
          }
        });
      }
    });

    jQuery('.search-geolocation').click( function() {
      try {
        navigator.geolocation.getCurrentPosition( function(position) {
          // Success
          var latitude  = Math.ceil(position.coords.latitude*10000) / 10000;
          var longitude = Math.ceil(position.coords.longitude*10000) / 10000;
          var origin = latitude+','+longitude;
          jQuery('#origin').val(origin);
        }, function (error) {
          // Error
        }, { enableHighAccuracy: true });
      } catch (e) {
        alert('Your web browser doesn\'t support this feature');
      }
    });
  });
</script>
-->

</#escape>
