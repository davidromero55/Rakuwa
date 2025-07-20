use Rakuwa::Conf;
use Rakuwa::View;
use Template6;
use Rakuwa::DB;
use HTML::Escape;

class Rakuwa::DBTable is Rakuwa::View {
    has $.id is rw = "";
    has Str $.title is rw = '';
    has $.name is rw = "Rakuwa::DBTable";
    has $.template is rw = 'db-table';
    has $.request is rw;
    has @.path is rw = ();

    has $.auto_order is rw = True;
    has $.pagination is rw = True;
    has $.nav_pages is rw = 5;
    has %.custom_labels is rw = {};
    has $.key_column is rw = '';
    has $.hidde_key_column is rw = True;
    has %.detail is rw = {
        :Tr({
            :params_a({:class("zl_row_a")}),
            :params_b({:class("zl_row_b")}),
        }),
        :td({
            :params({}),
        }),
    };
    has %.no_data_td is rw = {
        :class("zl_no_data"),
        :align("center"),
    };
    has %.labels is rw = {
        :page_of("Page _PAGE_ of _OF_"),
        :no_data("No records found"),
        :link_up("&uarr;"),
        :link_down("&darr;"),
        :next_page("&raquo;"),
        :previous_page("&laquo;"),
        :number_of_rows("_NUMBER_ records"),
    };
    has $.display_rows_total is rw = True;

    has @.data;
    has %.query is rw = {
        :select("*"),
        :from(""),
        :where(""),
        :order_by(""),
        :group_by(""),
        :limit(0),
    };

    has %.links is rw = {
        :location(""),
        :transit_params({}),
    };

    has %.table-attrs is rw = {
        :class("table table-striped table-bordered table-sm rounded-1"),
        :width("100%"),
        :align("center"),
        :cellspacing("0"),
    };
    has $.caption is rw = '';
    has @.columns = [];
    has $.rows_details = '';
    has $.pagination-details = '';

    method init () {


    }

    method get-data () {
        if (@.data) {
            # Data already fetched, no need to fetch again
            return;
        }
        # Fetch data from the database based on the SQL query
        my $db = get-db;
        my $sql = "SELECT " ~ %.query<select> ~ " FROM " ~ %.query<from>;

        if %.query<where>:exists {
            $sql ~= " WHERE " ~ %.query<where>;
        }

        if %.query<group_by>:exists {
            $sql ~= " GROUP BY " ~ %.query<group_by>;
        }

        if %.query<order_by>:exists {
            $sql ~= " ORDER BY " ~ %.query<order_by>;
        }

        if %.query<limit>:exists && %.query<limit> > 0 {
            $sql ~= " LIMIT " ~ %.query<limit>;
        }

        my $statement = $db.db.prepare($sql);
        my $result = $statement.execute;
        @!columns = $result.names;
        @!data = $result.hashes;
    }

    method get-columns (-->Str) {
        # Prepare the columns for the table
        my $columns-str = '';
        for @!columns -> $col {
            if ($col eq $.key_column && $.hidde_key_column) {
                # Skip hidden key column
                next;
            }
            my $label;
            if (%.custom_labels{$col}:exists) {
                $label = %.custom_labels{$col};
            } else {
                $label = $col;
                $label = $label.subst(/_/,' ', :g).subst(/^\w/, { $/.uc });
            }
            $columns-str ~= "<th>" ~ $label ~ "</th>";
        }
        return $columns-str;
    }

    method get-details (-->Str) {
        # Prepare the details for the table rows
        my $details-str = '';
        if @!data.elems == 0 {
            # No data available, return no data message
            $details-str ~= "<tr><td ";
            for %.no_data_td.kv -> $key, $value {
                $details-str ~= "$key=\"$value\" ";
            }
            my $colspan = @!columns.elems;
            if $.hidde_key_column {
                $colspan--;
            }
            $details-str ~= "colspan=\"" ~ $colspan ~ "\">" ~ %.labels<no_data> ~ "</td></tr>";
            return $details-str;
        }
        for @!data -> $row {
            my $row-class = ($.rows_details eq 'alternate') ?? 'zl_row_a' !! 'zl_row_b';
            $details-str ~= "<tr class=\"$row-class\">";
            for @!columns -> $col {
                my $value = $row{$col} // '';
                if ($col eq $.key_column && $.hidde_key_column) {
                    # Skip hidden key column
                    next;
                }
                $details-str ~= "<td>" ~ $value ~ "</td>";
            }
            $details-str ~= "</tr>";
        }
        return $details-str;
    }

    method get-table-start () {
        # Prepare the table start HTML
        my $table_attrs = '';
        for %.table-attrs.kv -> $key, $value {
            $table_attrs ~= "$key=\"$value\" ";
        }
        return '<table ' ~ $table_attrs ~ '>';
    }

    method render (%vars={}) {
        # Prepare the view for rendering

        self.get-data();

        $.status = 200;
        my $template = $.template;
        my $TT = Template6.new(:include-path([%.conf<Template><template_dir> ~ '/']));
        $TT.add-path(%.conf<Template><template_dir> ~ '/');


        $.content = $TT.process($.template,
                :title($.title),
                :msg(self.get-msgs),
                :table-start(self.get-table-start),
                :caption($.caption),
                :columns(self.get-columns),
                :details(self.get-details),
                :pagination($.pagination),
                :debug(%.conf<App><debug>)
                );
    }

}
