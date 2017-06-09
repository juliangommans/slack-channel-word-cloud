window.onload = function () {

  var myData = JSON.parse(data);

  function buildJsonData (json) {
    var ary = [];
    for (var name in json) {
      // console.log(json[name]);
      if (json.hasOwnProperty(name))
        var dataPointAry = [];
        for (var key in json[name]) {
          // console.log(key, json[name]);
          if (json[name].hasOwnProperty(key)) {
            dataPointAry.push({
              x: parseInt(key),
              y: parseInt(json[name][key])
            });
          }
        }
        ary.push({
          name: name,
          type: "line",
          showInLegend: true,
          dataPoints: dataPointAry
        });
      }


    // json.forEach(function(item){
    //   var dataPointAry = [];
    //   for (var key in item) {
    //     if (item.hasOwnProperty(key)) {
    //       dataPointAry.push({
    //         x: key,
    //         y: parseInt(item[key])
    //       });
    //     }
    //   }
    //   ary.push({
    //     type: "line",
    //     dataPoints: dataPointAry
    //   });
    // })
    return ary.slice(0,10);
  }

  var manipulatedData = buildJsonData(myData);

  var oldData = [
    {
      type: "line",

      "dataPoints": [
      { x: new Date(2012, 00, 1), y: 450 },
      { x: new Date(2012, 01, 1), y: 414 },
      { x: new Date(2012, 02, 1), y: 520 },
      { x: new Date(2012, 03, 1), y: 460 },
      { x: new Date(2012, 04, 1), y: 450 },
      { x: new Date(2012, 05, 1), y: 500 },
      { x: new Date(2012, 06, 1), y: 480 },
      { x: new Date(2012, 07, 1), y: 480 },
      { x: new Date(2012, 08, 1), y: 410 },
      { x: new Date(2012, 09, 1), y: 500 },
      { x: new Date(2012, 10, 1), y: 480 },
      { x: new Date(2012, 11, 1), y: 510 }
      ]
    }, {
      type: "line",
      "dataPoints": [
      { x: new Date(2012, 00, 1), y: 40 },
      { x: new Date(2012, 01, 1), y: 44 },
      { x: new Date(2012, 02, 1), y: 50 },
      { x: new Date(2012, 03, 1), y: 40 },
      { x: new Date(2012, 04, 1), y: 40 },
      { x: new Date(2012, 05, 1), y: 50 },
      { x: new Date(2012, 06, 1), y: 40 },
      { x: new Date(2012, 07, 1), y: 40 },
      { x: new Date(2012, 08, 1), y: 40 },
      { x: new Date(2012, 09, 1), y: 50 },
      { x: new Date(2012, 10, 1), y: 40 },
      { x: new Date(2012, 11, 1), y: 50 }
      ]
    }]

  console.log(manipulatedData);
  console.log(oldData);

  var chart = new CanvasJS.Chart("chartContainer",
  {

    title:{
    text: "Slack Word Graph"
    },
     data: manipulatedData
  });

  chart.render();
}
