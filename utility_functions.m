% this function given an area of interest in the environment, returns a
% string containing the union of traingles ids that are inside the srea of
% interest. In triangles we are actually passing the incenter coordinates
% of each triangle
function [first_function,second_function] = utility()
    function s = inverse_observation_mapping(polygon,triangles)

    s = "";
    first = 1;
    for(i=1:size(triangles,1))
        xq = triangles(i,1);
        yq = triangles(i,2);
        in = inpolygon(xq,yq,polygon(:,1),polygon(:,2));
        if in == 1
            % the triangles is inside the polygon of interest
            if first == 1
                s = s + i;
                first = 0;
            else
                s = s + " | " + i;
            end
        end
    end
    end

    % this function creates the transation from each state(triangles) given
    % the dual graph after the triangulation, so having the neighbours

    function s = create_transations(N)
        s =  sprintf("next(state) := case");
        for(i=1:size(N,1))
            s = s + sprintf("\n\t\t      state = ") + i + " : {"; % we are using 6 blank spaces after last tab
            for(j=1:3)
                n = N(i,j);
                if isnan(n) == 0
                    %so the neighbour is actually defined and it exists
                    if j == 1
                        s = s + n;
                    else
                        s = s+", " + n;
                    end
                end
            end
            s = s + "};";
        end
        s = s + sprintf("\n\t\t    esac;");
    end

first_function = @inverse_observation_mapping;
second_function = @create_transitions;
end