/**
* paging service
*
* Conversion Author:  Robert Cruz
* Conversion of original Paging plugin to coldbox 4 paging service utility.  Drop in your models folder.
* Also now has links to go to first and last record in addition to next and previous inks.
*
* To use this service you need to create some settings in your coldbox.cfc and some
* css entries.
* 
* COLDBOX SETTINGS
* - PagingMaxRows : The maximum number of rows per page.
* - PagingBandGap : The maximum number of pages in the page carrousel

* CSS SETTINGS:
* Now using bootstraps pagination css
* .nav aria-label="Page navigation" - The div container
* .pagingTabsTotals - The totals
* .pagination - The carrousel

* To use. You must use a "page" variable to move from page to page.
* ex: index.cfm?event=users.list&page=2

* In your handler you must calculate the boundaries to push into your paging query.
* inject the paging service: property name="pagingService" inject="model";
* prc.boundaries = pagingServince.getBoundaries()>
* Gives you a struct:
* [startrow] : the startrow to use
* [maxrow] : the max row in this recordset to use.
* Ex: [startrow=11][maxrow=20] if we are using a PagingMaxRows of 10

* FoundRows = The total rows found in the recordset
* link = The link to use for paging, including a placeholder for the page @page@
* 	ex: index.cfm?event=users.list&page=@page@

* To RENDER the paging carousel:
* Get an instance of the paging model:  p = getModel('pagingService');
* Call the rederit function: p.renderit(FoundRows,link, page).  
* A paging view has been created for this purpose which you include in your results template by using 
*	renderView('_templates/paging')

* see the index function of the stateProvince handler for an example of how to implement and integrate into an object result set

*/
component output="false"  {
	
	// injections - get the settings necessary for paging to work
	property name="pagingMaxRows" inject="coldbox:setting:pagingMaxRows";
	property name="PagingBandGap" inject="coldbox:setting:PagingBandGap";
	//Constructor

	public pagingService function init(){
		return this;
	}

	numeric function  getPagingMaxRows (pagingMaxRows) {
		if ( isDefined ( arguments.pagingMaxRows ) ) {
			pagingMaxRows = arguments.pagingMaxRows;
		}

		return PagingMaxRows = pagingMaxRows;
	}

	numeric function  getPagingBandGap () {
		return PagingBandGap = PagingBandGap;
	}
	
	any function  getBoundaries (page,pagingMaxRows) {
			var boundaries = structnew();
			//var page = arguments.page;
			var maxRows = getPagingMaxRows (pagingMaxRows);
			
			/* Check for Override need to come back to this */
			if( structKeyExists(arguments,"PagingMaxRows") ){
				maxRows = arguments.pagingMaxRows;
			}
						
			boundaries.startrow = (arguments.page * maxrows - maxRows)+1;
			boundaries.maxrow = boundaries.startrow + maxRows - 1;
		
			return boundaries;
	}
	
	any function renderit (FoundRows,link,page,pagingMaxRows) {
		
		var pagingTabs = "";
		var maxRows = getPagingMaxRows(pagingMaxRows);
		var bandGap = getPagingBandGap();
		var totalPages = 0;
		var theLink = arguments.link;
		//Paging vars --->
		var currentPage = arguments.page;
		var pageFrom = 0;
		var pageTo = 0;
		var pageIndex = 0;
		
		if ( arguments.foundRows neq 0 ) {
			totalPages = ceiling( arguments.FoundRows / maxRows );
		}
		// output pagination totals and carousel
		savecontent variable="pagingtabs" {
			writeOutput( '<nav aria-label="Page navigation">' );
			// output paging totals
			writeOutput( '<div class="pagingTabsTotals"><strong>Total Records: </strong>' & #arguments.FoundRows# &'&nbsp;&nbsp;' & '<strong>Total Pages: </strong>' & #totalPages# & '</div>');
			//start the pagination carousel
			writeOutput( '<ul class="pagination">' );
			// PREVIOUS PAGE --->
			if ( currentPage-1 gt 0 ) {
				writeOutput( '<li><a href="#replace(theLink,"@page@",1)#" aria-label="first"><span aria-hidden="true">&laquo;&laquo;</span></a></li>' );
				writeOutput( '<li><a href="#replace(theLink,"@page@",currentPage-1)#" aria-label="Previous"><span aria-hidden="true">&laquo;</span></a></li>' );
			} else {
				writeOutput ( '<li><span aria-hidden="true">&laquo;&laquo;</span></li><li><span aria-hidden="true">&laquo;</span></li>' );
			}
			// Calcualte PageFrom Carrousel --->
			pageFrom=1;
			
			if ( (currentPage-bandGap) gt 1 ) {
				pageFrom = currentPage-bandGap;
				writeOutput( '<li><a href="#replace(theLink,"@page@",1)#">1</a></li>' );
			}
			// Page TO of Carrousel --->
			pageTo = (currentPage+bandGap);
			
			if ( ( currentPage + bandGap ) gt totalPages ) {
				pageTo = totalPages;
			}
			
			var pageStatusClass = "";
			//loop and create each page link
			for (
					pageIndex = pageFrom;
					pageIndex LTE pageTo;
					pageindex ++
				)
				{
					if ( currentPage eq pageIndex ) {
						pageStatusClass='class="active"';
					}
					writeOutPut ( '<li #pageStatusClass#><a href="#replace(theLink,"@page@",pageIndex)#"' & '>' & #pageIndex# & '</a></li>');	
					pageStatusClass = "";
				}

			// End Token --->
			if ( ( currentPage + bandGap ) lt totalPages ) {
				writeOutput( '<li><a href="#replace(theLink,"@page@",totalPages)#">' & #totalPages# & '</a></li>' );
			}
			
			// NEXT PAGE --->
			if ( currentPage lt totalPages ) {
				writeOutput ( '<li><a href="#replace(theLink,"@page@",currentPage+1)#" aria-hidden="true"><span aria-hidden="true">&raquo;</span></a></li>' );
				writeOutput ( '<li><a href="#replace(theLink,"@page@",totalPages)#" aria-hidden="true"><span aria-hidden="true">&raquo;&raquo;</span></a></li>' );
			} else {
				writeOutput ( '<li><span aria-hidden="true">&raquo;</span></li>' );
				writeOutput ( '<li><span aria-hidden="true">&raquo;&raquo;</span></li>' )
			}

			writeOutPut( '</ul>' );
			writeOutPut( '</nav>' );
		}
		// this return is for testing only
		return pagingtabs;
	}
}
