const data_json = document.querySelector("script[type='application/json']").textContent;
const {edges, nodes} = JSON.parse(data_json);

class MyHandler extends Paged.Handler {
	constructor(chunker, polisher, caller) {
		super(chunker, polisher, caller);
	}

	afterRendered (){
		plot_network();
	}
}
Paged.registerHandlers(MyHandler);

function plot_network(){
  const {width, height} = document.querySelector("svg#cv_network_viz").getBoundingClientRect();

  const svg = d3.select("svg#cv_network_viz")
    .attr("width", width)
    .attr("height", height);

  const unique_sections = [...new Set(nodes.map(d => d.section))];
  const color_scale = d3.scaleOrdinal()
    .domain(unique_sections)
    .range(d3.schemeSet2);

  const edge_color = d3.scaleLinear()
    .domain(d3.extent(edges, d => d.year));

  const simulation = d3.forceSimulation(nodes)
    .force("link", d3.forceLink(edges).id(d => d.id))
    .force("charge", d3.forceManyBody())
    .force("center", d3.forceCenter(width / 2, height / 2))
    .on("tick", ticked);

  const g = svg.append("g");

  const link = g
    .selectAll("line")
    .data(edges)
    .enter().append("line")
      .attr("stroke", d => d3.interpolateGreys(edge_color(d.year)))
      .attr("stroke-width", 0.5);

  const node = g
    .attr("stroke", "#fff")
    .attr("stroke-width", 1.5)
    .selectAll("circle")
    .data(nodes)
    .enter().append("circle")
      .attr("r", 5)
      .attr("fill", d => color_scale(d.section))
      .call(drag(simulation));

  node.append("title")
      .text(d => `${d.section}\n${d.title}`);

  svg.call(d3.zoom()
      .extent([[0, 0], [width, height]])
      .scaleExtent([1, 8])
      .on("zoom", zoomed));

  function ticked() {
    link
        .attr("x1", d => d.source.x)
        .attr("y1", d => d.source.y)
        .attr("x2", d => d.target.x)
        .attr("y2", d => d.target.y);

    node
        .attr("cx", d => d.x)
        .attr("cy", d => d.y);
  }

  function zoomed() {
    g.attr("transform", d3.event.transform);
  }

  function drag(simulation){

    function dragstarted(d) {
      if (!d3.event.active) simulation.alphaTarget(0.3).restart();
      d.fx = d.x;
      d.fy = d.y;
    }

    function dragged(d) {
      d.fx = d3.event.x;
      d.fy = d3.event.y;
    }

    function dragended(d) {
      if (!d3.event.active) simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
    }

    return d3.drag()
        .on("start", dragstarted)
        .on("drag", dragged)
        .on("end", dragended);
  }

}
